#
# Be sure to run `pod lib lint URBNDataSource.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "URBNDataSource"
  s.version          = "0.1.0"
  s.summary          = "URBNDataSource is meant to be a convenience wrapper around UICollectionView / UITableView data management"
  s.description      = <<-DESC
                       An optional longer description of URBNDataSource

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/urbn/URBNDataSource"
  s.license          = 'MIT'
  s.author           = 'URBN Application Engineering Team'
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/URBNDataSource.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'URBNDataSource' => ['Pod/Assets/*.png']
  }
end
