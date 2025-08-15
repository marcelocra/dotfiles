import sublime
import sublime_plugin
import datetime
import threading
import time


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


class MarkdownNewHeadingCommand(sublime_plugin.TextCommand):
    """Create new heading 2 with current time in markdown files"""
    
    def run(self, edit):
        now = datetime.datetime.now()
        time_str = now.strftime("%Hh%M")
        heading = f"## {time_str} - "
        
        # Go to the end of the file
        file_end = self.view.size()
        
        # Check if we need to add line breaks (if file doesn't end with newline)
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
        
        # Show the new heading at top of screen
        self.view.show_at_center(new_pos)

        # NOTE: Initially, the idea was to move it to the top, but now I prefer
        # it at the center. To keep it at the top, uncomment the following.
        # # Actually move it to top (show_at_center then adjust)
        # sublime.set_timeout(lambda: self.move_to_top(new_pos), 50)
    
    def move_to_top(self, pos):
        """Move the position to top of screen"""
        self.view.set_viewport_position((0, self.view.text_to_layout(pos)[1] - 50))
    
    def is_enabled(self):
        """Only enable in markdown files"""
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
    
    def is_enabled(self):
        """Only enable in markdown files"""
        return self.view.match_selector(0, "text.html.markdown")


# Keep original commands for reference
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
