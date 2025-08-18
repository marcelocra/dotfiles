import datetime
import re
import threading

import sublime
import sublime_plugin


class StatusBarManager:
    """Manages status bar updates"""

    def __init__(self):
        self.timer = None
        self.is_running = False

    def start(self):
        if not self.is_running:
            self.is_running = True
            self.update_status()

    def stop(self):
        self.is_running = False
        if self.timer:
            self.timer.cancel()

    def update_status(self):
        if not self.is_running:
            return

        # Update datetime for all views
        now = datetime.datetime.now()
        date_time = now.strftime("%d%b%y %H:%M").lower()

        for window in sublime.windows():
            for view in window.views():
                view.set_status("datetime", date_time)
                self.update_count_status(view)

        # Schedule next update
        self.timer = threading.Timer(1.0, self.update_status)
        self.timer.start()

    def update_count_status(self, view):
        """Update character and word count in status bar"""
        total_chars = view.size()
        total_words = len(view.substr(sublime.Region(0, view.size())).split())
        view.set_status("word_count", f"{total_words} words, {total_chars} chars")


# Global status bar manager
status_manager = StatusBarManager()


def plugin_loaded():
    """Called when plugin is loaded"""
    status_manager.start()


def plugin_unloaded():
    """Called when plugin is unloaded"""
    status_manager.stop()


class UpdateStatusListener(sublime_plugin.EventListener):
    """Listen for events that should trigger status updates"""

    def on_selection_modified(self, view):
        status_manager.update_count_status(view)

    def on_activated(self, view):
        status_manager.update_count_status(view)

    def on_modified(self, view):
        status_manager.update_count_status(view)


# Global selection history tracker
class SelectionHistoryManager:
    def __init__(self):
        self.history = {}  # view_id -> list of selection states

    def push_selections(self, view):
        """Save current selections to history"""
        view_id = view.id()
        if view_id not in self.history:
            self.history[view_id] = []

        # Convert selections to tuples for storage
        current_selections = [(r.begin(), r.end()) for r in view.sel()]
        self.history[view_id].append(current_selections)

        # Limit history size to prevent memory issues
        if len(self.history[view_id]) > 50:
            self.history[view_id] = self.history[view_id][-50:]

    def pop_selections(self, view):
        """Restore previous selections from history"""
        view_id = view.id()
        if view_id not in self.history or not self.history[view_id]:
            return False

        # Get the previous selection state
        previous_selections = self.history[view_id].pop()

        # Apply the previous selections
        view.sel().clear()
        for start, end in previous_selections:
            view.sel().add(sublime.Region(start, end))

        return True

    def clear_history(self, view):
        """Clear history for a view"""
        view_id = view.id()
        if view_id in self.history:
            self.history[view_id].clear()


# Global instance
selection_history = SelectionHistoryManager()


class SelectionHistoryListener(sublime_plugin.EventListener):
    """Track expand_selection commands to build history"""

    def on_text_command(self, view, command_name, args):
        # Track when expand_selection is about to run
        if command_name == "expand_selection":
            selection_history.push_selections(view)
        return None

    def on_selection_modified(self, view):
        # Clear history if user manually changes selection
        # (with a small delay to avoid clearing during expand/shrink operations)
        sublime.set_timeout_async(lambda: self.maybe_clear_history(view), 100)

    def maybe_clear_history(self, view):
        # Only clear if we're not in the middle of an expand/shrink operation
        # This is a simple heuristic - in practice, manual selection changes
        # should reset the expansion history
        pass  # For now, we'll keep the history


class ShrinkSelectionCommand(sublime_plugin.TextCommand):
    """Shrink selection using history (like VSCode)"""

    def run(self, edit):
        # Try to restore previous selection from history
        if selection_history.pop_selections(self.view):
            return  # Successfully restored from history

        # If no history available, fall back to heuristic shrinking
        view = self.view
        new_selections = []

        for region in view.sel():
            if region.empty():
                new_selections.append(region)
                continue

            shrunk_region = self.shrink_region(view, region)
            new_selections.append(shrunk_region)

        # Replace selections
        view.sel().clear()
        for region in new_selections:
            view.sel().add(region)

    def shrink_region(self, view, region):
        """Fallback heuristic shrinking when no history available"""
        start = region.begin()
        end = region.end()
        text = view.substr(region)

        # Strategy 1: If selection includes surrounding brackets/quotes, remove them
        stripped = text.strip()
        if len(stripped) >= 2:
            bracket_pairs = [
                ("(", ")"),
                ("[", "]"),
                ("{", "}"),
                ('"', '"'),
                ("'", "'"),
                ("`", "`"),
            ]

            for open_br, close_br in bracket_pairs:
                if stripped.startswith(open_br) and stripped.endswith(close_br):
                    # Find actual bracket positions in original text
                    open_pos = text.find(open_br)
                    close_pos = text.rfind(close_br)
                    if close_pos > open_pos:
                        inner_text = text[open_pos + 1 : close_pos]
                        if inner_text.strip():  # Only shrink if there's content inside
                            return sublime.Region(
                                start + open_pos + 1, start + close_pos
                            )

        # Strategy 2: Multi-line to single line
        lines = text.splitlines()
        if len(lines) > 1:
            # Find first non-empty line
            for line in lines:
                if line.strip():
                    line_start = text.find(line.strip())
                    return sublime.Region(
                        start + line_start, start + line_start + len(line.strip())
                    )

        # Strategy 3: Multiple words to single word
        words = text.split()
        if len(words) > 1:
            first_word = words[0]
            word_pos = text.find(first_word)
            return sublime.Region(start + word_pos, start + word_pos + len(first_word))

        # Strategy 4: CamelCase word splitting
        camel_match = re.search(r"[a-z][A-Z]", text)
        if camel_match:
            split_pos = camel_match.start() + 1
            return sublime.Region(start, start + split_pos)

        # Strategy 5: Character shrinking
        if len(text) > 1:
            return sublime.Region(start, end - 1)

        # Can't shrink further
        return sublime.Region(start, start)


class FindUnderExpandSkipBackwardCommand(sublime_plugin.TextCommand):
    """Move focus backwards through multiple selections (like VSCode's behavior)"""

    def run(self, edit):
        view = self.view
        selections = list(view.sel())

        if not selections:
            return

        # Get the text from the first selection to search for
        if selections[0].empty():
            return

        search_text = view.substr(selections[0])
        if not search_text:
            return

        # This is the key insight: we want to move the "focus" (last selection)
        # to a previous occurrence while keeping other selections

        # Find all occurrences in the document
        all_regions = view.find_all(search_text, sublime.LITERAL)

        if len(all_regions) <= len(selections):
            return  # No more occurrences available

        # Find the last (focused) selection in the list of all occurrences
        last_selection = selections[-1]
        last_index = -1

        for i, region in enumerate(all_regions):
            if region.begin() == last_selection.begin():
                last_index = i
                break

        if last_index == -1:
            return

        # Move to previous occurrence (with wraparound)
        new_focus_index = (last_index - 1) % len(all_regions)
        new_focus_region = all_regions[new_focus_index]

        # Replace the last selection with the new focus
        new_selections = selections[:-1] + [new_focus_region]

        # Update selections
        view.sel().clear()
        for selection in new_selections:
            view.sel().add(selection)

        # Show the new focused selection
        view.show(new_focus_region)


class FindUnderExpandSkipForwardCommand(sublime_plugin.TextCommand):
    """Move focus forwards through multiple selections (like VSCode's behavior)"""

    def run(self, edit):
        view = self.view
        selections = list(view.sel())

        if not selections:
            return

        # Get the text from the first selection to search for
        if selections[0].empty():
            return

        search_text = view.substr(selections[0])
        if not search_text:
            return

        # Find all occurrences in the document
        all_regions = view.find_all(search_text, sublime.LITERAL)

        if len(all_regions) <= len(selections):
            return  # No more occurrences available

        # Find the last (focused) selection in the list of all occurrences
        last_selection = selections[-1]
        last_index = -1

        for i, region in enumerate(all_regions):
            if region.begin() == last_selection.begin():
                last_index = i
                break

        if last_index == -1:
            return

        # Move to next occurrence (with wraparound)
        new_focus_index = (last_index + 1) % len(all_regions)
        new_focus_region = all_regions[new_focus_index]

        # Replace the last selection with the new focus
        new_selections = selections[:-1] + [new_focus_region]

        # Update selections
        view.sel().clear()
        for selection in new_selections:
            view.sel().add(selection)

        # Show the new focused selection
        view.show(new_focus_region)


class ToggleMarkdownTaskCommand(sublime_plugin.TextCommand):
    """Toggle between '- text', '- [ ] text', and '- [x] text' in markdown"""

    def run(self, edit):
        view = self.view

        for region in view.sel():
            # Get the line containing the cursor
            line_region = view.line(region)
            line_text = view.substr(line_region)

            # Determine current state and next state
            new_text = self.toggle_task_state(line_text)

            # Replace the line
            view.replace(edit, line_region, new_text)

    def toggle_task_state(self, line_text):
        """Toggle between the three task states"""
        # Remove leading whitespace to analyze the content
        stripped = line_text.lstrip()
        leading_whitespace = line_text[: len(line_text) - len(stripped)]

        if stripped.startswith("- [x] "):
            # Completed task -> simple bullet
            content = stripped[6:]  # Remove '- [x] '
            return f"{leading_whitespace}- {content}"
        elif stripped.startswith("- [ ] "):
            # Incomplete task -> completed task
            content = stripped[6:]  # Remove '- [ ] '
            return f"{leading_whitespace}- [x] {content}"
        elif stripped.startswith("- "):
            # Simple bullet -> incomplete task
            content = stripped[2:]  # Remove '- '
            return f"{leading_whitespace}- [ ] {content}"
        else:
            # Not a list item, make it a simple bullet
            return f"{leading_whitespace}- {stripped}"

    def is_enabled(self):
        """Only enable in markdown files"""
        return self.view.match_selector(0, "text.html.markdown")


class MarkdownNewHeadingCommand(sublime_plugin.TextCommand):
    """Create new heading in markdown files - different behavior for tasks.md"""

    def run(self, edit):
        file_name = self.view.file_name()

        if file_name and file_name.endswith("tasks.md"):
            # tasks.md: heading without time, with Added timestamp
            self._create_tasks_heading(edit)
        else:
            # Regular markdown: heading with time
            self._create_regular_heading(edit)

    def _create_regular_heading(self, edit):
        """Create timestamped heading for regular markdown files"""
        now = datetime.datetime.now()
        time_str = now.strftime("%Hh%M")
        heading = f"## {time_str} - "

        # Go to the end of the file
        file_end = self.view.size()

        # Check if we need to add line breaks
        last_char = ""
        if file_end > 0:
            last_char = self.view.substr(sublime.Region(file_end - 1, file_end))

        # Prepare the text to insert
        if last_char != "\n":
            insert_text = f"\n\n{heading}"
        else:
            insert_text = f"\n{heading}"

        # Insert at end of file
        self.view.insert(edit, file_end, insert_text)

        # Position cursor at end of heading
        new_pos = file_end + len(insert_text)
        self.view.sel().clear()
        self.view.sel().add(sublime.Region(new_pos, new_pos))

        # Show the new heading at center of screen
        self.view.show_at_center(new_pos)

    def _create_tasks_heading(self, edit):
        """Create heading with Added timestamp for tasks.md"""
        heading = "## "
        now = datetime.datetime.now()
        added_text = f"\n_Added: {now.strftime('%Y-%m-%d %H:%M')}_"

        # Go to the end of the file
        file_end = self.view.size()

        # Check if we need to add line breaks
        last_char = ""
        if file_end > 0:
            last_char = self.view.substr(sublime.Region(file_end - 1, file_end))

        # Prepare the text to insert
        if last_char != "\n":
            insert_text = f"\n\n{heading}\n{added_text}"
        else:
            insert_text = f"\n{heading}\n{added_text}"

        # Insert at end of file
        self.view.insert(edit, file_end, insert_text)

        # Position cursor at end of heading (before the Added line)
        heading_end_pos = file_end + len(insert_text) - len(added_text) - 1
        self.view.sel().clear()
        self.view.sel().add(sublime.Region(heading_end_pos, heading_end_pos))

        # Show the new heading at center of screen
        self.view.show_at_center(heading_end_pos)

    def is_enabled(self):
        """Enable in all markdown files"""
        return self.view.match_selector(0, "text.html.markdown")


class ToggleLinePositionCommand(sublime_plugin.TextCommand):
    """Toggle current line between top, middle, bottom of screen"""

    def run(self, edit):
        # Get current cursor position
        cursor_pos = self.view.sel()[0].begin()

        # Get viewport info
        viewport_pos = self.view.viewport_position()
        visible_region = self.view.visible_region()

        # Get line position in layout coordinates
        line_layout_pos = self.view.text_to_layout(cursor_pos)[1]
        viewport_height = self.view.viewport_extent()[1]

        # Calculate relative position in viewport (0 = top, 1 = bottom)
        relative_pos = (line_layout_pos - viewport_pos[1]) / viewport_height

        # Determine next position based on current position
        if relative_pos < 0.3:  # Currently at top, move to middle
            target_y = line_layout_pos - viewport_height / 2
        elif relative_pos < 0.7:  # Currently at middle, move to bottom
            target_y = line_layout_pos - viewport_height + 100
        else:  # Currently at bottom, move to top
            target_y = line_layout_pos - 50

        # Set new viewport position
        self.view.set_viewport_position((viewport_pos[0], target_y))


class HelloWorldCommand(sublime_plugin.TextCommand):
    """A simple command that inserts 'Hello World!' at the cursor position"""

    def run(self, edit):
        for region in self.view.sel():
            self.view.insert(edit, region.begin(), "Hello World!")


class UppercaseSelectionCommand(sublime_plugin.TextCommand):
    """Convert selected text to uppercase"""

    def run(self, edit):
        for region in self.view.sel():
            if not region.empty():
                text = self.view.substr(region)
                self.view.replace(edit, region, text.upper())


class LowercaseSelectionCommand(sublime_plugin.TextCommand):
    """Convert selected text to lowercase"""

    def run(self, edit):
        for region in self.view.sel():
            if not region.empty():
                text = self.view.substr(region)
                self.view.replace(edit, region, text.lower())


class InsertTimestampCommand(sublime_plugin.TextCommand):
    """Insert current timestamp at cursor position"""

    def run(self, edit):
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        for region in self.view.sel():
            self.view.insert(edit, region.begin(), timestamp)


class InsertDateCommand(sublime_plugin.TextCommand):
    """Insert current date in [[YYYY-MM-DD]] format"""

    def run(self, edit):
        date_str = datetime.datetime.now().strftime("[[%Y-%m-%d]]")
        for region in self.view.sel():
            self.view.insert(edit, region.begin(), date_str)


class InsertTimeCommand(sublime_plugin.TextCommand):
    """Insert current time in HHhMM format"""

    def run(self, edit):
        time_str = datetime.datetime.now().strftime("%Hh%M")
        for region in self.view.sel():
            self.view.insert(edit, region.begin(), time_str)
