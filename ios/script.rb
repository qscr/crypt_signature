require 'xcodeproj'
path_to_project = "../example/ios/Pods/Pods.xcodeproj"
project = Xcodeproj::Project.open(path_to_project)
main_target = project.targets[1]
phase = main_target.new_shell_script_build_phase("Script Phase Custom")
phase.shell_script = "echo KKK"
project.save()