"""tktrans.py - various kinds of transient boxes for prompts and dialogs.
Ka-Ping Yee, 29 August 1999."""

# Copyright 1999 by Ka-Ping Yee.  All rights reserved.
# This file is part of the Udanax Green distribution.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions: 
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software. 
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL Ka-Ping Yee OR Udanax.com BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
# THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
# 
# Except as contained in this notice, "Udanax", "Udanax.com", and the
# transcluded-U logo shall not be used in advertising or otherwise to
# promote the sale, use or other dealings in this Software without
# prior written authorization from Udanax.com.

from Tkinter import *
import string

class TransientBox(Toplevel):
    """TransientBox - a transient window that is dismissed by choosing
    a button from a configurable row of buttons at the bottom."""

    def __init__(self, parent=None, title="Prompt", defaultbutton=None,
                 buttons=[("Okay", 1, ["Return"]), ("Cancel", 0, ["Escape"])]):
        Toplevel.__init__(self, parent)
        self.parent = parent
        if parent: self.transient(parent)
        self.title(title)
        self.buttons = buttons
        self.defaultbutton = defaultbutton
        self.focus_widget = self

        self.top_frame = Frame(self, bd=1, relief=RAISED)
        self.top_frame.pack(expand=1, fill=BOTH)
        self.bottom_frame = Frame(self, bd=1, relief=RAISED)
        self.bottom_frame.pack(expand=1, fill=BOTH)

        self.dismiss_btns = []
        self.dismiss_frame = Frame(self.bottom_frame)
        self.buildbuttons(self.dismiss_frame)
        self.dismiss_frame.pack(side=BOTTOM)

        Frame(self.top_frame).pack(side=BOTTOM, pady=3)
        self.body_frame = Frame(self.top_frame)
        self.buildbody(self.body_frame)
        self.body_frame.pack(expand=1, fill=BOTH, padx=15, pady=10)

        if self.parent:
            self.withdraw()
            self.update()
            self.centeron(self.parent)
            self.deiconify()

        self.result = None
        self.pressed = None

    def buildbody(self, parent):
        pass # pure virtual

    def buildbuttons(self, parent):
        index = 0
        for label, value, hotkeys in self.buttons:
            button = Button(parent, text=label,
                            command=lambda i=index, c=self.choose: c(i))
            button.pack(side=LEFT, padx=5, pady=5)
            self.dismiss_btns.append(button)
            for key in hotkeys:
                if key == "Return": self.defaultbutton = index
                press = lambda event, i=index, e=self.eh_key: e(i)
                release = lambda event, i=index, e=self.eh_keyrelease: e(i)
                self.bind("<KeyPress-%s>" % key, press)
                self.bind("<KeyRelease-%s>" % key, release)
            index = index + 1

        if self.defaultbutton is not None:
            defaultbutton = self.dismiss_btns[self.defaultbutton]
            try: # recent Tk feature
                defaultbutton.config(default=ACTIVE)
            except: # fallback for earlier versions of Tk
                defaultbutton.config(relief=GROOVE, bd=4)
            self.focus_widget = defaultbutton

    def centeron(self, other):
        x, y = other.winfo_rootx(), other.winfo_rooty()
        w, h = other.winfo_width(), other.winfo_height()
        myw, myh = self.winfo_reqwidth(), self.winfo_reqheight()
        myx, myy = x + w/2 - myw/2, y + h/2 - myh/2
        if myx < 0: myx = 0
        if myy < 0: myy = 0
        self.geometry("+%d+%d" % (myx, myy))

    def go(self):
        self.grab_set()
        self.focus_widget.focus_set()
        self.wait_window(self)
        return self.result

    def choose(self, index):
        label, value, hotkeys = self.buttons[index]
        self.result = value
        if self.parent: self.parent.focus_set()
        self.withdraw()
        self.destroy()

    def eh_key(self, index):
        self.pressed = index
        self.dismiss_btns[index].config(relief=SUNKEN, state=ACTIVE)

    def eh_keyrelease(self, index):
        if self.pressed == index:
            self.dismiss_btns[index].config(relief=RAISED, state=NORMAL)
            self.choose(index)

class MessageBox(TransientBox):
    """MessageBox - a transient box that contains just a message."""

    def __init__(self, parent=None, title="Message", text="Hello!",
                 buttons=[("Okay", 1, ["Return"])]):
        self.text = text
        TransientBox.__init__(self, parent, title, buttons=buttons)

    def buildbody(self, parent):
        self.text_msg = Message(parent, aspect=300,
                                text=self.text, justify=CENTER)
        self.text_msg.pack() #padx=15, pady=10)

class Dialog(TransientBox):
    """Dialog - a transient box that validates input when you press Okay."""

    def __init__(self, parent=None, title="Dialog"):
        TransientBox.__init__(self, parent, title)

    def choose(self, index):
        if index == 0:
            self.result = self.validate()
            if self.result is None:
                self.focus_widget.focus_set()
                return
        if index == 1:
            self.result = None
        if self.parent: self.parent.focus_set()
        self.withdraw()
        self.destroy()

    def validate(self):
        pass # pure virtual

class EntryDialog(Dialog):
    """EntryDialog - a dialog that presents a single entry field."""

    def __init__(self, parent=None, title="Entry",
                 prompt="Enter text:", value=""):
        self.prompt = prompt
        self.value = value
        Dialog.__init__(self, parent, title)
    
    def buildbody(self, parent):
        self.prompt_label = Label(parent, text=self.prompt, justify=LEFT)
        self.prompt_label.pack(side=TOP, anchor=W)
        Frame(parent).pack(side=TOP, pady=5)
        self.input_var = StringVar()
        self.input_var.set(self.value)
        self.input_entry = Entry(parent, textvariable=self.input_var)
        self.input_entry.pack(anchor=W, expand=1, fill=X)
        self.focus_widget = self.input_entry

    def validate(self):
        return self.input_var.get()

class IntegerDialog(EntryDialog):
    """IntegerDialog - a dialog that expects you to enter an integer."""

    def __init__(self, parent=None, title="Entry",
                 prompt="Enter an integer:", value="", min=None, max=None):
        self.min = min
        self.max = max
        EntryDialog.__init__(self, parent, title, prompt, str(value))

    def validate(self):
        try:
            result = string.atoi(self.input_var.get())
        except ValueError:
            error(self, "Please enter an integer.")
            return None
        if self.min is not None and result < self.min:
            error(self, "The minimum allowed value is %d." % self.min)
            return None
        if self.max is not None and result > self.max:
            error(self, "The maximum allowed value is %d." % self.max)
            return None
        return result

class ChoiceDialog(Dialog):
    """ChoiceDialog - a dialog that presents a group of radio buttons."""

    def __init__(self, parent=None, title="Choice",
                 prompt="Choose an option:", choices=[], default=0):
        """title: the title of the dialog window
        prompt: an informative string to display
        choices: a list of two-tuples (label, value) for the choices
        default: the index of the default choice in the choices list"""
        self.prompt = prompt
        self.choices = choices
        self.default = default
        self.choice_var = IntVar()
        Dialog.__init__(self, parent, title)

    def buildbody(self, parent):
        self.prompt_label = Label(parent, text=self.prompt, justify=LEFT)
        self.prompt_label.pack(side=TOP, anchor=W)
        Frame(parent).pack(side=TOP, pady=5)

        self.choice_frame = Frame(parent)
        self.choice_frame.pack()
        for i in range(len(self.choices)):
            label, value = self.choices[i]
            radio = Radiobutton(self.choice_frame, text=label, value=i,
                                variable=self.choice_var, anchor=W, padx=15)
            radio.pack(side=TOP, fill=X)

        self.choice_var.set(self.default)

    def validate(self):
        label, value = self.choices[self.choice_var.get()]
        return value

# convenience functions

def info(parent, message, title="Information"):
    return MessageBox(parent, title, message,
                      [("Okay", 1, ["Return"])]).go()

def error(parent, message, title="Error"):
    return info(parent, message, title)

def confirm(parent, prompt, title="Confirmation"):
    return MessageBox(parent, title, prompt,
                      [("Okay", 1, ["Return"]),
                       ("Cancel", 0, ["Escape"])]).go()

def ask(parent, prompt, title="Question"):
    return MessageBox(parent, title, prompt,
                      [("Yes", 1, ["Return", "y"]),
                       ("No", 0, ["Escape", "n"])]).go()

def choose(parent, choices, prompt="Choose an option:",
           title="Choice", default=0):
    return ChoiceDialog(parent, title, prompt, choices, default).go()

def getstring(parent, prompt="Enter text:", title="Entry", value=""):
    return EntryDialog(parent, title, prompt, value).go()

def getint(parent, prompt="Enter an integer:", title="Entry", value="",
           min=None, max=None):
    return IntegerDialog(parent, title, prompt, value, min, max).go()


if __name__ == "__main__":
    root = Tk()
    root.withdraw()
    print ask(root, "Ready to proceed?")
    print info(root, "This is a message box with some text in it. "
                     "Isn't this exciting?")
    print getstring(root)
    print getint(root, min=0, max=50)
    print choose(root, [("One", 1), ("Two", 2), ("Three", 3)], default=1)
