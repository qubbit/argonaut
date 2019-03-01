## Optional Server Configuration

By default argonaut writes to `<working_dir>/log/<env>.log` this file is not automatically logrotated. You can enable log rotation by symlinking the included config file to the log rotate directory.

```
ln -s /var/www/argonaut.ninja/argonaut/optional_config/argonaut_logrotate /etc/logrotate.d/argonaut
```
