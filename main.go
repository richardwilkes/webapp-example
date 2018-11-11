package main

import (
	"fmt"
	"runtime"

	"github.com/richardwilkes/toolbox/atexit"
	"github.com/richardwilkes/toolbox/cmdline"
	"github.com/richardwilkes/toolbox/log/jot"
	"github.com/richardwilkes/toolbox/log/jotrotate"
	"github.com/richardwilkes/webapp"
	"github.com/richardwilkes/webapp/driver"
)

func main() {
	runtime.LockOSThread() // This must be done before any threading starts

	cmdline.AppName = "Example"
	cmdline.AppCmdName = "example"
	cmdline.AppVersion = "0.1"
	cmdline.CopyrightYears = "2018"
	cmdline.CopyrightHolder = "Richard A. Wilkes"
	cmdline.AppIdentifier = "com.trollworks.webapp.example"
	cl := cmdline.New(true)
	jotrotate.ParseAndSetup(cl)

	webapp.WillFinishStartupCallback = finishStartup

	// Start only returns on error
	jot.Fatal(1, webapp.Start(driver.ForPlatform()))
	atexit.Exit(0)
}

func finishStartup() {
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
