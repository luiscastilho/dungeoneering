// dungeoneering - Virtual tabletop (VTT) for local, in-person RPG sessions
// Copyright  (C) 2019-2021  Luis Castilho

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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

  String logsDir;
  RotationConfig logFilesConfig;
  String lineSeparator;
  boolean writeLogFile;

  Logger(String _logLevelName, int _platform) {

    // Initial log level set to TRACE, redefined below
    logLevel = 1;

    if ( _platform == MACOS )
      logsDir = SystemUtils.getUserHome().getAbsolutePath() + "/Documents/dungeoneering/log";
    else if ( _platform == WINDOWS )
      logsDir = sketchPath().replaceAll("\\\\", "/") + "/log";
    else
      logsDir = sketchPath() + "/log";

    logFilesConfig = RotationConfig
      .builder()
      .file(logsDir + "/dungeoneering.log")
      .filePattern(logsDir + "/dungeoneering-%d{yyyyMMdd-HHmmss-SSS}.log")
      .policy(new SizeBasedRotationPolicy(500 * 1024)) // 500KB
      .callback(new LoggingRotationCallbackKeepLast(5)) // Keep last 5 rotated log files
      .build();

    lineSeparator = System.getProperty("line.separator");

    try {
      Files.createDirectories(Paths.get(logsDir));
      if ( Files.isDirectory(Paths.get(logsDir)) )
        writeLogFile = true;
    } catch ( Exception e ) {
      writeLogFile = false;
      error("Logger: Couldn't create log dir - logging to console only");
    }

    try {
        logLevel = logLevelLookup(_logLevelName);
        info("Logger: Log level set to " + _logLevelName);
    } catch ( Exception e ) {
        logLevel = INFO;
        error("Logger: Unknown log level \"" + _logLevelName + "\" - log level set to INFO");
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
      String logLine = "[" + dateTime + "] " + logLevelName + ": " + message;
      println(logLine);

      if ( writeLogFile ) {

        RotatingFileOutputStream logFile = null;
        try {
          logFile = new RotatingFileOutputStream(logFilesConfig);
          logFile.write(logLine.getBytes(StandardCharsets.UTF_8));
          logFile.write(lineSeparator.getBytes(StandardCharsets.UTF_8));
        } catch ( Exception e ) {
          println("ERROR: Logger: error writing log to file");
          println(ExceptionUtils.getStackTrace(e));
        } finally {
          if ( logFile != null )
            logFile.close();
        }

      }

    } catch ( Exception e ) {
      println("ERROR: Logger: error printing log");
      println(ExceptionUtils.getStackTrace(e));
    }

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

  class LoggingRotationCallbackKeepLast implements RotationCallback {

    int keepLastN;

    LoggingRotationCallbackKeepLast(int _keepLastN) {

      keepLastN = _keepLastN;

    }

    @Override
    void onTrigger(RotationPolicy policy, Instant instant) {}

    @Override
    void onOpen(RotationPolicy policy, Instant instant, OutputStream stream) {}

    @Override
    void onClose(RotationPolicy policy, Instant instant, OutputStream stream) {}

    @Override
    void onSuccess(RotationPolicy policy, Instant instant, File file) {

      try {

        File logsDir = new File(Logger.this.logsDir);
        File[] rotatedLogFiles = logsDir.listFiles((FileFilter) new AndFileFilter(FileFileFilter.INSTANCE, new WildcardFileFilter("dungeoneering-*.log")));

        if ( rotatedLogFiles.length > keepLastN ) {

          Arrays.sort(rotatedLogFiles, LastModifiedFileComparator.LASTMODIFIED_REVERSE);
          for ( int i = keepLastN; i < rotatedLogFiles.length; i++ )
            rotatedLogFiles[i].delete();

        }

      } catch ( Exception e ) {
        logger.error("Logger: Error rotating log files");
        logger.error(ExceptionUtils.getStackTrace(e));
        throw e;
      }

    }

    @Override
    void onFailure(RotationPolicy policy, Instant instant, File file, Exception error) {}

  }

}
