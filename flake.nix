{
  description = "Incr/decr brightness and notify";

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    light = "${pkgs.light}/bin/light";
    notifySend = "${pkgs.libnotify}/bin/notify-send";
    cut = "${pkgs.coreutils}/bin/cut";
    step = 5;
    appName = "changeBrightness";
    urgency = "low";
    expireTime = 2000;
  in {
    packages.x86_64-linux.brightness = pkgs.writeShellScriptBin "brightness" ''
      delta=$(case $(${light} -G) in
        0.00) echo 1;;
        1.00) echo ${toString (step - 1)};;
        *)    echo ${toString step};;
      esac)

      case $1 in
        up)   ${light} -A $delta;;
        down) ${light} -U $delta;;
      esac

      brightness=$(${light} -G | ${cut} --delimiter '.' --fields 1)

      ${notifySend} \
        --app-name ${appName} \
        --urgency ${urgency} \
        --expire-time ${toString expireTime} \
        --hint string:x-dunst-stack-tag:brightness \
        --hint int:value:$brightness \
        "Brightness $brightness%"

      ${light} -G
    '';
    packages.x86_64-linux.default = self.packages.x86_64-linux.brightness;

  };
}
