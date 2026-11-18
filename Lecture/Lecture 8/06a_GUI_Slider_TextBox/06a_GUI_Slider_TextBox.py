# CSS452 Lecture 8 - guizero — a Slider whose value is shown in a TextBox.
# Run on the Pi in Thonny (Run) or: python3 06a_GUI_Slider_TextBox.py  (Ctrl+C to stop)

from guizero import App, Slider, TextBox

def slider_changed(slider_value):
    textbox.value = slider_value

app = App()
slider = Slider(app, command=slider_changed)
textbox = TextBox(app)
app.display()
