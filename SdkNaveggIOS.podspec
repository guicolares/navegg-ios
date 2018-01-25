s.name = "Navegg-IOS"
 
//versão da sua lib — branch que você criou no git
s.version = "1.0"
 
//resumo da descrição da sua lib
s.summary = "Library used in the tracker users."
 
//descrição da sua lib
//A descrição precisa ser diferente do resumo. Se for igual, não irá passar no teste).
s.description = "Library to tracker, custom, segments and onBoarding"
 
//link da sua lib no GitHub
s.homepage = "https://github.com/Navegg/navegg-ios.git"
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.author = { "Navegg" => "it@navegg.com" }
s.source = { :git => "https://github.com/Navegg/navegg-ios.git", :tag => s.version.to_s }
 
//Se tiver Twitter, coloque a url aqui
s.social_media_url = ''
 
//path das suas classes
s.source_files = Pod/Classes/**/*.{h,m}
