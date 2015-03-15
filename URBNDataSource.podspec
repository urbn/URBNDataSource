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
  s.version          = '0.5.1'
  s.summary          = 'URBNDataSource is meant to be a convenience wrapper around UICollectionView / UITableView data management'
  s.homepage         = 'https://github.com/urbn/URBNDataSource'
  s.license          = 'MIT'
  s.author           = { "urbn" => "jgrandelli@urbn.com" }
  s.source           = { :git => "https://github.com/urbn/URBNDataSource.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'
end
