# frozen_string_literal: true

json.array! @events do |event|
  json.event event[:event]
  json.status event[:status]
  json.sold event[:sold]
end

# typicaly, we would pass an activerecord object to this jbuilder file and access the attributes using event.status.
# However, here we're passing a hash object so we need to access the attributes as a hash
# note to self, I have removed the patial
