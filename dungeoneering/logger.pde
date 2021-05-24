import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

class Logger {

  static final int CRITICAL = 7;
  static final int ERROR = 6;
  static final int WARNING = 5;
  static final int NOTICE = 4;
  static final int INFO = 3;
  static final int DEBUG = 2;
  static final int TRACE = 1;

  int log_level;

  DateTimeFormatter dateTimeformatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

  Logger(String _log_level_name) {

    try {
        log_level = logLevelLookup(_log_level_name);
    } catch ( Exception e ) {
        error("Unknown log level \"" + _log_level_name + "\" - log level set to INFO");
        log_level = INFO;
    }

  }

  Integer logLevelLookup(String _log_level_name) throws Exception {

    switch ( _log_level_name ) {
      case "CRITICAL":
        return CRITICAL;
      case "ERROR":
        return ERROR;
      case "WARNING":
        return WARNING;
      case "NOTICE":
        return NOTICE;
      case "INFO":
        return INFO;
      case "DEBUG":
        return DEBUG;
      case "TRACE":
        return TRACE;
      default:
        throw new Exception("Unknown log level " + _log_level_name);
    }

  }

  String logLevelNameLookup(int _log_level) throws Exception {

    switch ( _log_level ) {
      case CRITICAL:
        return "CRITICAL";
      case ERROR:
        return "ERROR";
      case WARNING:
        return "WARNING";
      case NOTICE:
        return "NOTICE";
      case INFO:
        return "INFO";
      case DEBUG:
        return "DEBUG";
      case TRACE:
        return "TRACE";
      default:
        throw new Exception("Unknown log level " + _log_level);
    }

  }

  void log(int log_level, String message) {

    try {
      String dateTime = dateTimeformatter.format(LocalDateTime.now());
      String logLevelName = logLevelNameLookup(log_level);
      println("[" + dateTime + "] " + logLevelName + ": " + message);
    } catch ( Exception e ) {}

  }

  void critical(String message) {

    if ( log_level < CRITICAL )
      return;
    log(CRITICAL, message);

  }

  void error(String message) {

    if ( log_level < ERROR )
      return;
    log(ERROR, message);

  }

  void warning(String message) {

    if ( log_level < WARNING )
      return;
    log(WARNING, message);

  }

  void notice(String message) {

    if ( log_level < NOTICE )
      return;
    log(NOTICE, message);

  }

  void info(String message) {

    if ( log_level < INFO )
      return;
    log(INFO, message);

  }

  void debug(String message) {

    if ( log_level < DEBUG )
      return;
    log(DEBUG, message);

  }

  void trace(String message) {

    if ( log_level < TRACE )
      return;
    log(TRACE, message);

  }

}
