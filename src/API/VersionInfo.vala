public class Olifant.API.VersionInfo {
    public uint major;
    public uint minor;
    public uint patch;

    public VersionInfo(uint _major = 0, uint _minor = 0, uint _patch = 0) {
        major = _major;
        minor = _minor;
        patch = _patch;
    }

    public static VersionInfo parse(string ver) {
        var info = new VersionInfo ();
        string[] parts = ver.split(".");

        if (parts[0] != null)
            info.major = parts[0].to_int();

        if (parts[1] != null)
            info.minor = parts[1].to_int();

        if (parts[2] != null)
            info.patch = parts[2].to_int();

        return info;
    }

    public string show () {
        return "VersionInfo(major=%u, minor=%u, patch=%u)".printf (major, minor, patch);
    }
}
