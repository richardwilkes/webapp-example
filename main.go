package main

import (
	"fmt"

	"github.com/richardwilkes/toolbox/atexit"
	"github.com/richardwilkes/toolbox/cmdline"
	"github.com/richardwilkes/toolbox/log/jot"
	"github.com/richardwilkes/toolbox/log/jotrotate"
	"github.com/richardwilkes/webapp"
	"github.com/richardwilkes/webapp/driver"
)

func main() {
	cmdline.AppName = "Example"
	cmdline.AppCmdName = "example"
	cmdline.AppVersion = "0.1"
	cmdline.CopyrightYears = "2018"
	cmdline.CopyrightHolder = "Richard A. Wilkes"
	cmdline.AppIdentifier = "com.trollworks.webapp.example"

	jot.FatalIfErr(webapp.Initialize(driver.ForPlatform()))

	cl := cmdline.New(true)
	jotrotate.ParseAndSetup(cl)

	webapp.WillFinishStartupCallback = finishStartup

	// Start only returns on error
	jot.FatalIfErr(webapp.Start())
	atexit.Exit(0)
}

func finishStartup() {
	wnd, err := webapp.NewWindow(webapp.StdWindowMask, webapp.MainDisplay().UsableBounds, "Example", "https://youtube.com")
	jot.FatalIfErr(err)
	bar := webapp.MenuBarForWindow(wnd)
	_, aboutItem, prefsItem := bar.InstallAppMenu()
	aboutItem.Handler = func() { fmt.Println("About menu item selected") }
	prefsItem.Handler = func() { fmt.Println("Preferences menu item selected") }
	bar.InstallEditMenu()
	bar.InstallWindowMenu()
	bar.InstallHelpMenu()
	wnd.ToFront()
}
