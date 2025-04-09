{
  system.defaults = {
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        # "disable" Writing of .DS_Store files on network or USB volumes
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.finder" = {
        # disable all animation
        DisableAllAnimations = true;
        # warning before emptying the Trash
        WarnOnEmptyTrash = false;
        # expanded info panes in Finder
        FXInfoPanesExpanded = {
          General = true;
          OpenWith = true;
        };
      };
      NSGlobalDomain = {
        # set scroll rubber banding / elastic scrolling
        NSScrollViewRubberbanding = 0;
        # quick look animation
        QLPanelAnimationDuration = 0.0;
        # showing a toolbar or menu bar in full screen
        NSToolbarFullScreenAnimationDuration = 0.0;
        # scrolling column views
        NSBrowserColumnAnimationSpeedMultiplier = 0.0;
      };
      "com.apple.dock" = {
        # show launchpad
        springboard-show-duration = 0.0;
        # hide launchpad
        springboard-hide-duration = 0.0;
        # change page in launchpad
        springboard-page-duration = 0.0;
      };
      "com.apple.TimeMachine" = {
        # prevent Time Machine from prompting to use
        # new hard drives as backup volume
        DoNotOfferNewDisksForBackup = true;
      };
      "com.apple.SoftwareUpdate" = {
        # automatic update check
        AutomaticCheckEnabled = true;
        # check for software updates daily
        ScheduleFrequency = 1;
        # install System data files & security updates
        CriticalUpdateInstall = 1;
      };
    };
    NSGlobalDomain = {
      # level of font smoothing (sub-pixel font rendering)
      AppleFontSmoothing = 2;
      # whether to use 24-hour or 12-hour time
      AppleICUForce24HourTime = true;
      # set to "Dark" to enable dark mode, or leave unset for normal mode.
      AppleInterfaceStyle = "Dark";
      # use centimeters (metric) or inches (US, UK) as the measurement unit.
      # the default is based on region settings.
      AppleMeasurementUnits = "Centimeters";
      # use the metric system.
      # the default is based on region settings
      AppleMetricUnits = 1;
      # enable the press-and-hold feature.
      # The default is true.
      ApplePressAndHoldEnabled = false;
      # jump to the spot that’s clicked on the scroll bar
      AppleScrollerPagingBehavior = true;
      # when to show the scrollbars.
      # options are "WhenScrolling", "Automatic" and "Always".
      AppleShowScrollBars = "Always";
      # whether to use Celsius or Fahrenheit
      AppleTemperatureUnit = "Celsius";
      "com.apple.mouse.tapBehavior" = 1;
      # expanded save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      # expanded save panel by default
      NSNavPanelExpandedStateForSaveMode2 = true;
      # Sets the speed speed of window resizing
      NSWindowResizeTime = 0.0;
      # save new documents to iCloud by default.
      NSDocumentSaveNewDocumentsToCloud = false;
      #  enable automatic spelling correction
      NSAutomaticSpellingCorrectionEnabled = false;
      # enable “Natural” scrolling direction
      "com.apple.swipescrolldirection" = false;
      # enable automatic capitalization
      NSAutomaticCapitalizationEnabled = false;
      # enable inline predictive text
      NSAutomaticInlinePredictionEnabled = false;
      # enable smart dash substitution
      NSAutomaticDashSubstitutionEnabled = false;
      # enable smart period substitution
      NSAutomaticPeriodSubstitutionEnabled = false;
      # animate opening and closing of windows and popovers
      NSAutomaticWindowAnimationsEnabled = false;
      # enable smart quote substitution
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSTableViewDefaultSizeMode = 3;
      "com.apple.springing.enabled" = false;
      # set the spring loading delay for directories
      "com.apple.springing.delay" = 0.0;
      # enable the focus ring animation
      NSUseAnimatedFocusRing = false;
      # configures the trackpad tracking speed (0.0 to 3.0). The default is “1.0”.
      "com.apple.trackpad.scaling" = 1.5;
    };
    finder = {
      # always show file extensions
      AppleShowAllExtensions = true;
      # always show hidden files
      AppleShowAllFiles = true;
      # show icons on the desktop or not
      CreateDesktop = false;
      # default search scope. `SCcf` -> search the current folder
      FXDefaultSearchScope = "SCcf";
      # show warnings when change the file extension of files
      FXEnableExtensionChangeWarning = false;
      # change the default finder view. "Nlsv" -> List view
      FXPreferredViewStyle = "Nlsv";
      # remove items in the trash after 30 days
      FXRemoveOldTrashItems = true;
      # default folder shown in Finder windows
      NewWindowTarget = "Documents";
      # show status bar at bottom of finder windows with item/disk space stats
      ShowStatusBar = true;
      # show path breadcrumbs in finder windows
      ShowPathbar = true;
      # show the full POSIX filepath in the window title
      _FXShowPosixPathInTitle = true;
      # keep folders on top when sorting by name
      _FXSortFoldersFirst = true;
    };
    dock = {
      # automatically hide and show the dock
      autohide = true;
      # speed of the autohide delay
      autohide-delay = 0.0;
      # speed of the animation when hiding/showing the Dock
      autohide-time-modifier = 0.0;
      # hide Dashboard as a Space
      dashboard-in-overlay = false;
      # enable-spring-load-actions-on-all-items
      enable-spring-load-actions-on-all-items = false;
      # speed of the Mission Control animations
      expose-animation-duration = 0.0;
      # group windows by application in Mission Control’s Exposé
      expose-group-apps = false;
      # animate opening applications from the Dock
      launchanim = false;
      # magnify icon on hover
      magnification = false;
      # minimize windows to application icon
      minimize-to-application = true;
      # automatically rearrange spaces based on most recent use
      mru-spaces = false;
      # size of the icons in the dock
      tilesize = 65;
      # show process indicators
      show-process-indicators = true;
      # show recent applications in the dock
      show-recents = false;
      # make icons of hidden applications tranclucent
      showhidden = true;
      # hot corner action for bottom left corner. 1 -> disabled
      wvous-bl-corner = 1;
      # hot corner action for bottom right corner. 1 -> disabled
      wvous-br-corner = 1;
      # hot corner action for top left corner. 1 -> disabled
      wvous-tl-corner = 1;
      # hot corner action for top right corner. 1 -> disabled
      wvous-tr-corner = 1;
    };
    menuExtraClock = {
      # show a 24-hour clock, instead of a 12-hour clock
      Show24Hour = true;
      # show the clock with second precision, instead of minutes
      ShowSeconds = true;
    };
    controlcenter = {
      # Show a battery percentage in menu bar
      BatteryShowPercentage = true;
      # Show a sound control in menu bar
      Sound = true;
    };
    trackpad = {
      # enable trackpad tap to click
      Clicking = true;
    };
    ActivityMonitor = {
      # change which processes to show. 100 -> All processes
      ShowCategory = 100;
      # which column to sort the main activity page
      SortColumn = "CPUUsage";
      # sort direction of the sort column. 0 -> descending
      SortDirection = 0;
    };
    LaunchServices = {
      # enable quarantine for downloaded applications
      LSQuarantine = false;
    };
    spaces = {
      # displays have separate Spaces
      # Apple menu > System Preferences > Mission Control
      # false = each physical display has a separate space (mac default)
      spans-displays = false;
    };
    # https://github.com/mathiasbynens/dotfiles/issues/820#issuecomment-498324762
    # https://github.com/LnL7/nix-darwin/issues/1049#issuecomment-2323300537
    # add terminal to full disk access permission
    universalaccess = {
      # set the size of cursor. 1 for normal, 4 for maximum.
      mouseDriverCursorSize = 1.3;
      # disable animation when switching screens or opening apps
      reduceMotion = true;
      # disable transparency in the menu bar and elsewhere.
      reduceTransparency = true;
    };
  };
}
