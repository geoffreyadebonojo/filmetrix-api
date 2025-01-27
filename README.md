# README


<h1>Filmetrix</h1>

Ruby 3.1.3
Rails 7.0.4


<h3>Setup</h3>

```
git clone https://github.com/geoffreyadebonojo/filmetrix-api.git Filmetrix
```


<h3>Database </h3>

```
rake db:{create,seed,migrate}
```


<h3>Not-uncommon environment issues</h3>


This happens from time to time:
```
ActiveRecord::ConnectionNotEstablished (connection to server on socket "/tmp/.s.PGSQL.5432" failed: No such file or directory
        Is the server running locally and accepting connections on that socket?
):
```
ugh. god. what a pain.
Was getting errors in postgres.

helpful for checking stuff:
```
brew services info postgresql
```

[helpful](https://stackoverflow.com/questions/41844331/how-to-brew-uninstall-postgres-on-ox-sierra)

Solution: ended up uninstalling pg14
```
brew uninstall postgresql@14
brew install postgresql@14
```