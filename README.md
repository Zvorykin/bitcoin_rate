# Bitcoin Fake Rates

Pet project improve some SQL skills.

Using Ruby 2.7.1

Fetch Bitcoin rate, seed fake data, show rate chart for periods 1 year, 1 month, 1 week, 1 day and 1 hour, filling missing data.


Setup as usual 
```
bundle
rails db:create db:migrate

rails -s
http://127.0.0.1:3000/

rails db:seed       # to generate lots of data
```

Start `sidekiq` to start receiving new data.

