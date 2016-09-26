object @locations
  attributes :id, :name, :address,:city,:state,:country, :lat, :long, :distance
  node :logo do |loc|
    loc.logo.fullpath if loc.logo
  end
