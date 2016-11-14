require 'dogapi'

api_key = "e60c5ab22bf9d09a7fe9c4b552b60c12"
application_key = "294aec6388fadc0dfc276f9d575a755b312c4146"

dog = Dogapi::Client.new(api_key, application_key)

# Get points from the last hour
from = Time.now - 600
to = Time.now
query = 'neto.infrastructure.free_trial.count{*}by{host}'
test = dog.get_points(query, from, to)

series = test[1]['series'].first

total_free_trials = series['pointlist'].last.last
