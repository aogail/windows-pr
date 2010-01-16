require 'rake'
require 'rake/testtask'
require 'rbconfig'
include Config

desc "Install the windows-pr package (non-gem)"
task :install do
   sitelibdir         = CONFIG["sitelibdir"]
	installdir         = File.join(sitelibdir, 'windows')
	installdir_msvcrt  = File.join(installdir, 'msvcrt')
   installdir_gdi     = File.join(installdir, 'gdi')
   installdir_com     = File.join(installdir, 'com')
   installdir_network = File.join(installdir, 'network')
   installdir_window  = File.join(installdir, 'window')
   installdir_ntfs    = File.join(installdir, 'ntfs')
   
   FileUtils.mkdir_p(installdir)
   FileUtils.mkdir_p(installdir_msvcrt)
   FileUtils.mkdir_p(installdir_gdi)
   FileUtils.mkdir_p(installdir_com)
   FileUtils.mkdir_p(installdir_network)
   FileUtils.mkdir_p(installdir_window)
   FileUtils.mkdir_p(installdir_ntfs)
   
   Dir["lib/windows/*.rb"].each{ |file|
      FileUtils.cp(file, installdir, :verbose => true)
   }
   
   Dir["lib/windows/msvcrt/*.rb"].each{ |file|
      FileUtils.cp(file, installdir_msvcrt, :verbose => true)
   }
   
   Dir["lib/windows/gdi/*.rb"].each{ |file|
      FileUtils.cp(file, installdir_gdi, :verbose => true)
   }
   
   Dir["lib/windows/com/*.rb"].each{ |file|
      FileUtils.cp(file, installdir_com, :verbose => true)
   }
   
   Dir["lib/windows/network/*.rb"].each{ |file|
      FileUtils.cp(file, installdir_network, :verbose => true)
   }
   
   Dir["lib/windows/window/*.rb"].each{ |file|
      FileUtils.cp(file, installdir_window, :verbose => true)
   } 
   
   Dir["lib/windows/ntfs/*.rb"].each{ |file|
      FileUtils.cp(file, installdir_ntfs, :verbose => true)
   }           
end

desc "Install the windows-pr package as a gem"
task :install_gem do
   ruby 'windows-pr.gemspec'
   file = Dir["*.gem"].first
   sh "gem install #{file}"
end

Rake::TestTask.new do |t|
   t.warning = true
   t.test_files = FileList['test/tc*']
end

Rake::TestTask.new('test-clipboard') do |t|
   t.warning = true
   t.verbose = true
   t.test_files = FileList['test/tc_clipboard.rb']
end
