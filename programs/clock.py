from tkinter import Tk
from tkinter import Label
import time

root = Tk()
root.title("Clock")

def present_time():
    display_time = time.time()
    clock.config(text=display_time)
    clock.after(200,present_time)

clock = Label(root, font=("arial", 150), bg="red", fg="black")
clock.pack()

present_time()
root.mainloop()
