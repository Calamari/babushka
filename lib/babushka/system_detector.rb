module Babushka
  class SystemDetector
    def self.profile_for_host
      (detect_using_uname || UnknownSystem).new
    end

    private

    def self.detect_using_uname
      case ShellHelpers.shell('uname -s')
      when 'Darwin';    OSXSystemProfile
      when 'DragonFly'; DragonFlySystemProfile
      when 'FreeBSD';   FreeBSDSystemProfile
      when 'Linux';     detect_using_release_file || LinuxSystemProfile
      end
    end

    def self.detect_using_release_file
      if File.exists?('/etc/debian_version')
        detect_debian_derivative
      elsif File.exists?('/etc/arch-release')
        ArchSystemProfile
      elsif File.exists?('/etc/fedora-release')
        FedoraSystemProfile
      elsif File.exists?('/etc/centos-release')
        CentOSSystemProfile
      elsif File.exists?('/etc/redhat-release')
        RedhatSystemProfile
      elsif File.exists?('/etc/SuSE-release')
        SuseSystemProfile
      end
    end

    def self.detect_debian_derivative
      if File.exists?('/etc/lsb-release')
        lsb_release = File.read('/etc/lsb-release')
        if lsb_release[/ubuntu/i]
          UbuntuSystemProfile
        elsif lsb_release[/elementary/i]
          ElementarySystemProfile
        else
          DebianSystemProfile
        end
      elsif File.exists?('/etc/os-release') && File.read('/etc/os-release')[/ID=raspbian/]
        RaspbianSystemProfile
      else
        DebianSystemProfile
      end
    end

  end
end
