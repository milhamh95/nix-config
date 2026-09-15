{
  den.aspects.system-defaults.darwin.system.defaults = {
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.finder" = {
        DisableAllAnimations = true;
        WarnOnEmptyTrash = false;
        FXInfoPanesExpanded = {
          General = true;
          OpenWith = true;
        };
      };
      NSGlobalDomain = {
        NSScrollViewRubberbanding = 0;
        QLPanelAnimationDuration = 0.0;
        NSToolbarFullScreenAnimationDuration = 0.0;
        NSBrowserColumnAnimationSpeedMultiplier = 0.0;
      };
      "com.apple.dock" = {
        springboard-show-duration = 0.0;
        springboard-hide-duration = 0.0;
        springboard-page-duration = 0.0;
      };
      "com.apple.TimeMachine" = {
        DoNotOfferNewDisksForBackup = true;
      };
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        ScheduleFrequency = 1;
        CriticalUpdateInstall = 1;
      };
    };

    NSGlobalDomain = {
      AppleFontSmoothing = 2;
      AppleICUForce24HourTime = true;
      AppleInterfaceStyle = "Dark";
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      ApplePressAndHoldEnabled = false;
      AppleScrollerPagingBehavior = true;
      AppleShowScrollBars = "Always";
      AppleTemperatureUnit = "Celsius";
      "com.apple.mouse.tapBehavior" = 1;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSWindowResizeTime = 0.0;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      "com.apple.swipescrolldirection" = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticWindowAnimationsEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSTableViewDefaultSizeMode = 3;
      "com.apple.springing.enabled" = false;
      "com.apple.springing.delay" = 0.0;
      NSUseAnimatedFocusRing = false;
      "com.apple.trackpad.scaling" = 1.5;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      CreateDesktop = true;
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      FXRemoveOldTrashItems = true;
      NewWindowTarget = "Documents";
      ShowStatusBar = true;
      ShowPathbar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      dashboard-in-overlay = false;
      enable-spring-load-actions-on-all-items = false;
      expose-animation-duration = 0.0;
      expose-group-apps = false;
      launchanim = false;
      magnification = false;
      minimize-to-application = true;
      mru-spaces = false;
      show-process-indicators = true;
      show-recents = false;
      showhidden = true;
      static-only = false;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      tilesize = 65;
      persistent-apps = [
        { spacer = { small = true; }; }
      ];
    };

    menuExtraClock = {
      Show24Hour = true;
      ShowSeconds = true;
    };

    controlcenter = {
      Sound = true;
      # Note: BatteryShowPercentage is set per-host
    };

    trackpad = {
      Clicking = true;
    };

    ActivityMonitor = {
      ShowCategory = 100;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };

    LaunchServices = {
      LSQuarantine = false;
    };

    spaces = {
      spans-displays = false;
    };

    # https://github.com/mathiasbynens/dotfiles/issues/820#issuecomment-498324762
    # https://github.com/LnL7/nix-darwin/issues/1049#issuecomment-2323300537
    universalaccess = {
      mouseDriverCursorSize = 1.3;
      reduceMotion = true;
      reduceTransparency = true;
    };

    WindowManager = {
      EnableStandardClickToShowDesktop = false;
    };
  };
}
