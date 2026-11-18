# CSS452 Lecture 8 - guizero — a PushButton that calls a function.
# Run on the Pi in Thonny (Run) or: python3 06b_GUI_PushButton.py  (Ctrl+C to stop)

from guizero import App, PushButton

def do_nothing():
    print("Button was pressed")

app = App()
button = PushButton(app, command=do_nothing)
app.display()
