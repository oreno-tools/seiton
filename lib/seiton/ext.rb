class String
  def queue_name
    res = self.split('/')
    return '' if res.empty?
    res.last
  end
end
