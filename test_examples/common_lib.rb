## The common library could have all common methods which will be shared by different test suites
module CommonLib
  def random
    return rand(1000001)+1000002
  end
end