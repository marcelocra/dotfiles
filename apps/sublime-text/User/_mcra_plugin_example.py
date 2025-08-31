# import sublime
# import sublime_plugin


# class HelloWorldCommand(sublime_plugin.TextCommand):
#     """
#     A simple command that inserts 'Hello World!' at the cursor position
#     """
#     def run(self, edit):
#         # Insert text at each cursor/selection
#         for region in self.view.sel():
#             self.view.insert(edit, region.begin(), "Hello World!")


# class UppercaseSelectionCommand(sublime_plugin.TextCommand):
#     """
#     Convert selected text to uppercase
#     """
#     def run(self, edit):
#         for region in self.view.sel():
#             if not region.empty():
#                 # Get the selected text
#                 text = self.view.substr(region)
#                 # Replace it with uppercase version
#                 self.view.replace(edit, region, text.upper())


# class InsertTimestampCommand(sublime_plugin.TextCommand):
#     """
#     Insert current timestamp at cursor position
#     """
#     def run(self, edit):
#         import datetime
#         timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

#         for region in self.view.sel():
#             self.view.insert(edit, region.begin(), timestamp)


# class TogglePyStyleCommentCommand(sublime_plugin.TextCommand):
#     """
#     Simple line comment toggler for Python-style comments
#     """
#     def run(self, edit):
#         for region in self.view.sel():
#             # Get the line containing the cursor
#             line = self.view.line(region)
#             line_text = self.view.substr(line)

#             # Toggle comment
#             if line_text.strip().startswith('#'):
#                 # Remove comment
#                 new_text = line_text.replace('#', '', 1).lstrip()
#             else:
#                 # Add comment
#                 new_text = '# ' + line_text

#             self.view.replace(edit, line, new_text)


# class ShowFileInfoCommand(sublime_plugin.TextCommand):
#     """
#     Show basic file information in a popup
#     """
#     def run(self, edit):
#         view = self.view
#         file_name = view.file_name() or "Untitled"
#         line_count = view.rowcol(view.size())[0] + 1
#         char_count = view.size()

#         info = f"""
# File: {file_name}
# Lines: {line_count}
# Characters: {char_count}
#         """

#         sublime.message_dialog(info.strip())
