platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Realm'
      create_symlink_phase = target.shell_script_build_phases.find { |x| x.name == 'Create Symlinks to Header Folders' }
      create_symlink_phase.always_out_of_date = "1"
    end
  end
end

target 'TodoList' do
  
  use_frameworks!
  
  # Pods for TodoList
  pod 'RealmSwift', '10.44.0'
  pod 'SwipeCellKit'
  
  
end
