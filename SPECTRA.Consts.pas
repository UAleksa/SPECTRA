unit SPECTRA.Consts;

interface

const
  WM_USER = 1024;
  CM_DESTROING = WM_USER + 1;
  CRLF = sLineBreak;

resourcestring
  //Collections
  sListIsSorted = 'Operation %s is not avaliable. Collection Sorted.';
  sDuplicatesNotAllowed = 'List does not allow duplicates';
  sOutOfRange = 'Argument out of range';
  sCapacityError = 'List capacity out of bounds (%d)';

  sNodeIsAttached = 'Node alreday attached to list';
  sNodeIsAttachedAnother = 'Node alreday attached to another list';
  sNodeNotSpecified = 'Parameter Node not specified';
  sNodeNotAssigned = 'Node not assigned';
  sListNoContainsNode = 'List doesn''''t contains node';
  sModeNotSupported = 'Mode %s not supported in %s';

  //Async
  sInvalidExit = 'Before closing the application, ''%s'' must be stopped';
  sInvalidStart  = 'The background worker named ''%s'' is already running';
  sWorkIsNil = 'Work proc is not set in worker ''%s''';
  sWaitNotRealized = 'WaitFor is not realized';

  //Enumerable
  sConditionIsNotSpecifed = 'Condition is not specified.';
  sCollectionNotContainElement = 'Collection does not contain element.';
  sCollectionIsEmpty = 'Collection is empty.';
  sFunctionNotAssigned = 'Function not assigned.';
  sProcNotAssigned = 'Procedure not assigned.';
  sSelectorNotAssigned = 'Selector not assigned.';
  sEnumerableTypeMismatch = 'Enumerable type must be Double or Int64';
  sMethodNotSupport = '%s not support';
  sParamsMismatch = 'Method parameters mismatch';

  //Log
  sAppendersListEmpty = 'Appenders list is empty';

  //Exception
  sExceptionClass = 'Exception class: %s';
  sExceptionMessage = 'Exception message: %s';
  sExceptionAddr = 'Exception address: %p';
  sStackList = 'Stack list, generated %s';
  sExceptionStack = 'Exception stack';
  sDetailsIntro = 'Exception log with detailed tech info. Generated on %s.' + string(#13#10) +
                  ' Application title: %s' + string(#13#10) +
                  ' Application file: %s';

implementation

end.
