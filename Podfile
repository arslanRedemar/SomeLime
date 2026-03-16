platform :ios, '17.0'

target 'Somlimee' do
  use_frameworks!
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Swinject'
  pod 'SQLite.swift', '~> 0.14.0'

  target 'SomlimeeTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Fix DT_TOOLCHAIN_DIR deprecation
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }

      # Force minimum deployment target
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 17.0
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      end

      # Remove '-GCC_WARN_INHIBIT_ALL_WARNINGS' from BoringSSL-GRPC
      # Clang parses it as unsupported '-G' flag; '-w' already suppresses warnings
      if target.name == 'BoringSSL-GRPC'
        target.source_build_phase.files.each do |file|
          if file.settings && file.settings['COMPILER_FLAGS']
            file.settings['COMPILER_FLAGS'] = file.settings['COMPILER_FLAGS'].gsub('-GCC_WARN_INHIBIT_ALL_WARNINGS', '')
          end
        end
      end
    end
  end
end
