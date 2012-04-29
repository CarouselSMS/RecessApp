def run_spellcheck(file,interactive=false)
  if interactive
    cmd = "aspell -p ./config/devver_dictionary -H check #{file}"
    puts cmd
    system(cmd)
    [true,""]
  else
    cmd = "aspell -p ./config/devver_dictionary -H list < #{file}"
    puts cmd
    results = `#{cmd}`
    [results.empty?, results]
  end
end

task :spellcheck => 'spellcheck:interactive'

namespace :spellcheck do
  files = FileList['app/views/**/*.html.erb', 'app/views/**/*.html.haml']

  desc "Spellcheck interactive"
  task :interactive do
    files.each do |file|
      run_spellcheck(file,true)
    end
    puts "spelling check complete"
  end

  desc "Spellcheck for ci"
  task :ci do
    files.each do |file|
      success, results = run_spellcheck(file)
      unless success
        puts results
        exit 1
      end
    end
    puts "no spelling errors"
    exit 0
  end
end