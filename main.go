package main

import (
	"fmt"

	"github.com/richardwilkes/toolbox/log/jot"
	"github.com/richardwilkes/webapp"
)

func main() {
	webapp.WillFinishStartupCallback = func() {
		wnd := webapp.NewWindow(webapp.StdWindowMask, webapp.MainDisplay().UsableBounds, "https://youtube.com")
		wnd.SetTitle("Example")
		bar := webapp.MenuBarForWindow(wnd)
		_, aboutItem, prefsItem := bar.InstallAppMenu()
		aboutItem.Handler = func() { fmt.Println("About menu item selected") }
		prefsItem.Handler = func() { fmt.Println("Preferences menu item selected") }
		bar.InstallEditMenu()
		bar.InstallWindowMenu()
		bar.InstallHelpMenu()
		wnd.ToFront()
	}
	// Start only returns on error
	jot.Fatal(1, webapp.Start())
}
