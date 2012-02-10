require 'ffi'

module Windows
  module SystemInfo
    extend FFI::Library
    ffi_lib 'kernel32'

    private

    class OSVERSIONINFO < FFI::Struct
      layout(
        :dwOSVersionInfoSize, :ulong,
        :dwMajorVersion, :ulong,
        :dwMinorVersion, :ulong,
        :dwBuildNumber, :ulong,
        :dwPlatformId, :ulong,
        :szCSDVersion, [:char, 128]
      )
    end

    class OSVERSIONINFOEX < FFI::Struct
      layout(
        :dwOSVersionInfoSize, :ulong,
        :dwMajorVersion, :ulong,
        :dwMinorVersion, :ulong,
        :dwBuildNumber, :ulong,
        :dwPlatformId, :ulong,
        :szCSDVersion, [:char, 128],
        :wServicePackMajor, :ushort,
        :wServicePackMinor, :ushort,
        :wSuiteMask, :ushort,
        :wProductType, :uchar,
        :wReserved, :uchar
      )
    end

    # Obsolete processor info constants

    PROCESSOR_INTEL_386     = 386
    PROCESSOR_INTEL_486     = 486
    PROCESSOR_INTEL_PENTIUM = 586
    PROCESSOR_INTEL_IA64    = 2200
    PROCESSOR_AMD_X8664     = 8664

    # Suite mask constants

    VER_SERVER_NT                      = 0x80000000
    VER_WORKSTATION_NT                 = 0x40000000
    VER_SUITE_SMALLBUSINESS            = 0x00000001
    VER_SUITE_ENTERPRISE               = 0x00000002
    VER_SUITE_BACKOFFICE               = 0x00000004
    VER_SUITE_COMMUNICATIONS           = 0x00000008
    VER_SUITE_TERMINAL                 = 0x00000010
    VER_SUITE_SMALLBUSINESS_RESTRICTED = 0x00000020
    VER_SUITE_EMBEDDEDNT               = 0x00000040
    VER_SUITE_DATACENTER               = 0x00000080
    VER_SUITE_SINGLEUSERTS             = 0x00000100
    VER_SUITE_PERSONAL                 = 0x00000200
    VER_SUITE_BLADE                    = 0x00000400
    VER_SUITE_EMBEDDED_RESTRICTED      = 0x00000800
    VER_SUITE_SECURITY_APPLIANCE       = 0x00001000
    VER_SUITE_STORAGE_SERVER           = 0x00002000
    VER_SUITE_COMPUTE_SERVER           = 0x00004000

    # Product mask constants

    VER_NT_WORKSTATION       = 0x0000001
    VER_NT_DOMAIN_CONTROLLER = 0x0000002
    VER_NT_SERVER            = 0x0000003

    # Platform definitions

    VER_PLATFORM_WIN32s        = 0
    VER_PLATFORM_WIN32_WINDOWS = 1
    VER_PLATFORM_WIN32_NT      = 2

    # Version info type constants

    VER_MINORVERSION     = 0x0000001
    VER_MAJORVERSION     = 0x0000002
    VER_BUILDNUMBER      = 0x0000004
    VER_PLATFORMID       = 0x0000008
    VER_SERVICEPACKMINOR = 0x0000010
    VER_SERVICEPACKMAJOR = 0x0000020
    VER_SUITENAME        = 0x0000040
    VER_PRODUCT_TYPE     = 0x0000080

    # Enum COMPUTER_NAME_FORMAT

    ComputerNameNetBIOS                    = 0
    ComputerNameDnsHostname                = 1
    ComputerNameDnsDomain                  = 2
    ComputerNameDnsFullyQualified          = 3
    ComputerNamePhysicalNetBIOS            = 4
    ComputerNamePhysicalDnsHostname        = 5
    ComputerNamePhysicalDnsDomain          = 6
    ComputerNamePhysicalDnsFullyQualified  = 7
    ComputerNameMax                        = 8

    attach_function :ExpandEnvironmentStringsA, [:string, :pointer, :ulong], :ulong
    attach_function :ExpandEnvironmentStringsW, [:string, :pointer, :ulong], :ulong
    attach_function :GetComputerNameA, [:pointer, :pointer], :bool
    attach_function :GetComputerNameW, [:pointer, :pointer], :bool
    attach_function :GetComputerNameExA, [:ulong, :pointer, :pointer], :bool
    attach_function :GetComputerNameExW, [:ulong, :pointer, :pointer], :bool
    attach_function :GetSystemInfo, [:pointer], :void
    attach_function :GetVersion, [], :ulong
    attach_function :GetVersionExA, [:pointer], :bool
    attach_function :GetVersionExW, [:pointer], :bool
    attach_function :GetWindowsDirectoryA, [:pointer, :uint], :uint
    attach_function :GetWindowsDirectoryW, [:pointer, :uint], :uint
    attach_function :QueryPerformanceCounter, [:pointer], :bool
    attach_function :QueryPerformanceFrequency, [:pointer], :bool

    ffi_lib 'advapi32'

    attach_function :GetUserNameA, [:pointer, :pointer], :bool
    attach_function :GetUserNameW, [:pointer, :pointer], :bool

    ffi_lib 'secur32'

    attach_function :GetUserNameExA, [:ulong, :pointer, :pointer], :bool
    attach_function :GetUserNameExW, [:ulong, :pointer, :pointer], :bool

    begin
       attach_function :GetSystemWow64Directory, [:pointer, :uint], :uint
    rescue FFI::NotFoundError
       # XP or later
    end

    # These macros are from windef.h, but I've put them here for now
    # since they can be used in conjunction with some of the functions
    # declared in this module.

    def MAKEWORD(a, b)
      ((a & 0xff) | ((b & 0xff) << 8))
    end

    def MAKELONG(a, b)
      ((a & 0xffff) | ((b & 0xffff) << 16))
    end

    def LOWORD(l)
      l & 0xffff
    end

    def HIWORD(l)
      l >> 16
    end

    def LOBYTE(w)
      w & 0xff
    end

    def HIBYTE(w)
      w >> 8
    end

    # Returns a float indicating the major and minor version of Windows,
    # e.g. 5.1, 6.0, etc.
    #
    def windows_version
      version = GetVersion()
      major = LOBYTE(LOWORD(version))
      minor = HIBYTE(LOWORD(version))
      Float("#{major}.#{minor}")
    end

    # Custom methods that may come in handy

    # Returns true if the current platform is Vista (any variant) or Windows
    # Server 2008, i.e. major version 6, minor version 0.
    #
    def windows_2000?
      version = GetVersion()
      LOBYTE(LOWORD(version)) == 5 && HIBYTE(LOWORD(version)) == 0
    end

    # Returns true if the current platform is Windows XP or Windows XP
    # Pro, i.e. major version 5, minor version 1 (or 2 in the case of a
    # 64-bit Windows XP Pro).
    #--
    # Because of the exception for a 64-bit Windows XP Pro, we have to
    # do things the hard way. For version 2 we look for any of the suite
    # masks that might be associated with Windows 2003. If we don't find
    # any of them, assume it's Windows XP.
    #
    def windows_xp?
      bool = false

      buf = OSVERSIONINFOEX.new
      buf[:dwOSVersionInfoSize] = OSVERSIONINFOEX.size

      GetVersionExA(buf)

      major = buf[:dwMajorVersion]
      minor = buf[:dwMinorVersion]
      suite = buf[:wSuiteMask]

      # Make sure we detect a 64-bit Windows XP Pro
      if major == 5
        if minor == 1
          bool = true
        elsif minor == 2
          if (suite & VER_SUITE_BLADE == 0)          &&
             (suite & VER_SUITE_COMPUTE_SERVER == 0) &&
             (suite & VER_SUITE_DATACENTER == 0)     &&
             (suite & VER_SUITE_ENTERPRISE == 0)     &&
             (suite & VER_SUITE_STORAGE_SERVER == 0)
          then
            bool = true
          end
        else
          # Do nothing - already false
        end
      end

      bool
    end

    # Returns true if the current platform is Windows 2003 (any version).
    # i.e. major version 5, minor version 2.
    #--
    # Because of the exception for a 64-bit Windows XP Pro, we have to
    # do things the hard way. For version 2 we look for any of the suite
    # masks that might be associated with Windows 2003. If we find any
    # of them, assume it's Windows 2003.
    #
    def windows_2003?
      bool = false

      buf = OSVERSIONINFOEX.new
      buf[:dwOSVersionInfoSize] = OSVERSIONINFOEX.size

      GetVersionExA(buf)

      major = buf[:dwMajorVersion]
      minor = buf[:dwMinorVersion]
      suite = buf[:wSuiteMask]

      # Make sure we exclude a 64-bit Windows XP Pro
      if major == 5 && minor == 2
        if (suite & VER_SUITE_BLADE > 0)          ||
           (suite & VER_SUITE_COMPUTE_SERVER > 0) ||
           (suite & VER_SUITE_DATACENTER > 0)     ||
           (suite & VER_SUITE_ENTERPRISE > 0)     ||
           (suite & VER_SUITE_STORAGE_SERVER > 0)
        then
          bool = true
        end
      end

      bool
    end

    # Returns true if the current platform is Windows Vista (any variant)
    # or Windows Server 2008, i.e. major version 6, minor version 0.
    #
    def windows_vista?
      version = GetVersion()
      LOBYTE(LOWORD(version)) == 6 && HIBYTE(LOWORD(version)) == 0
    end

    def windows_7?
      version = GetVersion()
      LOBYTE(LOWORD(version)) == 6 && HIBYTE(LOWORD(version)) == 1
    end
  end
end
