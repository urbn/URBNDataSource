#
# Be sure to run `pod lib lint URBNDataSource.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'URBNDataSource'
  s.version          = '2.0.0'
  s.summary          = 'URBNDataSource is meant to be a convenience wrapper around UICollectionView / UITableView data management'
  s.homepage         = 'https://github.com/urbn/URBNDataSource'
  s.license          = 'MIT'
  s.author           = { "urbn" => "jgrandelli@urbn.com" }
  s.source           = { :git => "https://github.com/urbn/URBNDataSource.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes'
  s.tvos.deployment_target = '9.0'
end
