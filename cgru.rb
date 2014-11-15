require "formula"


class Cgru < Formula
  homepage "http://cgru.info"
  url "https://github.com/CGRU/cgru", :using => :git, :tag => '2.0.3'
  head "https://github.com/CGRU/cgru", :using => :git

  option "with-sql", "Enable postgresql support"
  option "without-gui", "Disable GUI support"

  depends_on "cmake" => :build
  depends_on "imagemagick" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on "pyqt" => [:recommended, "with-python3"]
  depends_on "postgresql" => :build if build.with? "sql"


  def install
    ENV["AF_PYTHON_INCLUDE_PATH"]="/usr/local/Frameworks/Python.framework/Versions/3.4/include/python3.4m"
    ENV["AF_PYTHON_LIBRARIES"]="/usr/local/Frameworks/Python.framework/Versions/3.4/lib/libpython3.4m.dylib"
    ENV["AF_GUI"]="YES"
    ENV["AF_POSTGRESQL"]="NO"
    ENV["AF_GUI"]="NO" if build.without? "gui"
    ENV["AF_POSTGRESQL"]="YES" if build.with? "sql"

    cd('afanasy/src/project.cmake') do
        #args = std_cmake_args
        system "cmake", ".", *std_cmake_args
        system "make -j9"
    end

    exclude = Array.new()
    exclude.push(*["--exclude",".git"])
    exclude.push(*["--exclude",".gitignore"])
    exclude.push(*["--exclude","*.cmd"])
    exclude.push(*["--exclude","__pycache__"])
    exclude.push(*["--exclude","utilities/qt"])
    exclude.push(*["--exclude","utilities/python"])
    exclude.push(*["--exclude","utilities/ffmpeg"])
    exclude.push(*["--exclude","utilities/imagemagick"])
    exclude.push(*["--exclude","utilities/openexr"])
    exclude.push(*["--exclude","utilities/download"])
    exclude.push(*["--exclude","utilities/release"])
    exclude.push(*["--exclude","utilities/exrjoin"])
    exclude.push(*["--exclude","utilities/build.sh"])
    exclude.push(*["--exclude","utilities/distribution.sh"])
    exclude.push(*["--exclude","utilities/install_depends_devel.sh"])
    exclude.push(*["--exclude","afanasy/src"])
    exclude.push(*["--exclude","afanasy/archives"])
    exclude.push(*["--exclude","afanasy/init"])
    exclude.push(*["--exclude","afanasy/package"])

    system "rsync","-av", "#{buildpath}/",prefix, *exclude
  end


  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>#{plist_name}</string>
            <key>KeepAlive</key>
            <true/>
            <key>EnvironmentVariables</key>
            <dict>
                <key>PATH</key>
                <string>/bin:/usr/bin:/opt/cgru/bin:/usr/local/opt/cgru/afanasy/bin:/usr/local/opt/cgru/software_setup/bin</string>
                <key>CGRU_LOCATION</key>
                <string>/usr/local/opt/cgru</string>
                <key>CGRU_PYTHON</key>
                <string>/usr/local/opt/cgru/lib/python</string>
                <key>PYTHONPATH</key>
                <string>/usr/local/opt/cgru/afanasy/python:/usr/local/opt/cgru/lib/python</string>
                <key>AF_PYTHON</key>
                <string>/usr/local/opt/cgru/afanasy/python</string>
                <key>AF_ROOT</key>
                <string>/usr/local/opt/cgru/afanasy</string>
            </dict>
            <key>ProgramArguments</key>
            <array>
                <string>/usr/local/opt/cgru/afanasy/bin/afrender</string>
                <string>-V</string>
                <string>-noIPv6</string>
            </array>
            <!--
            <key>UserName</key>
            <string>irl</string>
            -->
            <key>WorkingDirectory</key>
            <string>#{HOMEBREW_PREFIX}</string>
            <key>StandardOutPath</key>
            <string>/var/log/afrender.log</string>
            <key>StandardErrorPath</key>
            <string>/var/log/afrender.log</string>
        </dict>
    </plist>
    EOS
  end


  test do
    system "true"
  end

end
