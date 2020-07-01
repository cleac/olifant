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
        var parts = ver.split(".");

        if (parts[0] != null)
            info.major = uint.parse(parts[0]);

        if (parts[1] != null)
            info.minor = uint.parse(parts[1]);

        if (parts[2] != null) 
            info.patch = uint.parse(parts[2]);

        return info;
    } 

    public string show () {
        return "VersionInfo(major=%u, minor=%u, patch=%u)".printf (major, minor, patch);
    }
}