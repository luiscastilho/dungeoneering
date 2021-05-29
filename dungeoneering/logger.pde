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

  int logLevel;

  DateTimeFormatter dateTimeformatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

  Logger(String _logLevelName) {

    try {
        logLevel = logLevelLookup(_logLevelName);
        info("Logger: Log level set to " + _logLevelName);
    } catch ( Exception e ) {
        error("Logger: Unknown log level \"" + _logLevelName + "\" - log level set to INFO");
        logLevel = INFO;
    }

  }

  Integer logLevelLookup(String _logLevelName) throws Exception {

    switch ( _logLevelName ) {
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
        throw new Exception("Unknown log level " + _logLevelName);
    }

  }

  String logLevelNameLookup(int _logLevel) throws Exception {

    switch ( _logLevel ) {
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
        throw new Exception("Unknown log level " + _logLevel);
    }

  }

  int getLogLevel() {
    return logLevel;
  }

  void log(int messageLogLevel, String message) {

    try {
      String dateTime = dateTimeformatter.format(LocalDateTime.now());
      String logLevelName = logLevelNameLookup(messageLogLevel);
      println("[" + dateTime + "] " + logLevelName + ": " + message);
    } catch ( Exception e ) {}

  }

  void critical(String message) {

    if ( logLevel > CRITICAL )
      return;
    log(CRITICAL, message);

  }

  void error(String message) {

    if ( logLevel > ERROR )
      return;
    log(ERROR, message);

  }

  void warning(String message) {

    if ( logLevel > WARNING )
      return;
    log(WARNING, message);

  }

  void notice(String message) {

    if ( logLevel > NOTICE )
      return;
    log(NOTICE, message);

  }

  void info(String message) {

    if ( logLevel > INFO )
      return;
    log(INFO, message);

  }

  void debug(String message) {

    if ( logLevel > DEBUG )
      return;
    log(DEBUG, message);

  }

  void trace(String message) {

    if ( logLevel > TRACE )
      return;
    log(TRACE, message);

  }

}
