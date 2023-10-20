# Glossary

* ready/due: See tasks.rb#task_ready?.  Indicates a task is ready for
  a person to work on it.  This is subtly different than what is used
  by Asana to mark a date as red/green!  A task is ready if it is not
  dependent on an incomplete task and one of these is true:

  * start is null and due on is today
  * start is null and due at is after now
  * start on is today
  * start at is after now
