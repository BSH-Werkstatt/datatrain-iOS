Pod::Spec.new do |s|
  s.name = 'SwaggerClient'
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '10.0'
  s.version = '0.0.1'
  s.source = { :git => 'git@github.com:swagger-api/swagger-mustache.git', :tag => 'v1.0.0' }
  s.authors = 'Swagger Codegen'
  s.license = 'Proprietary'
  s.source_files = 'SwaggerClient/Classes/**/*.swift'
  s.dependency 'Alamofire', '~> 5.0.0-beta.5'
s.homepage = 'ios19bsh.ase.in.tum.de'
s.summary = 'lorem ipsum'
end
