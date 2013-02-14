from buttleofx.core.undo_redo.manageTools import UndoableCommand


class CmdSetParamInt3D(UndoableCommand):
    """
        Command that update the value of a paramInt3D.
        Attributes :
        - param : the target param wich will be changed by the update
        - newValues : the value wich will be mofidy in the target
        - oldValues : the old value of the target param, wich will be used for reset the target in case of undo command
    """

    def __init__(self, param, newValues, index):
        self._param = param
        self._oldValues = (param.getOldValue1(), param.getOldValue2(), param.getOldValue3())
        self._newValues = newValues
        self._index = index

    def undoCmd(self):
        """
        Undoes the update of the param.
        """

        print "UNDO Int3D : ", self._index
        self._param.getTuttleParam().setValue(self._oldValues)
        self._param.setOldValueAt(int(self._oldValues[int(self._index)]), self._index)
        self._param.changed()

        from buttleofx.data import ButtleDataSingleton
        buttleData = ButtleDataSingleton().get()
        buttleData.updateMapAndViewer()

    def redoCmd(self):
        """
        Redoes the update of the param.
        """
        print "REDO Int3D : ", self._index
        return self.doCmd()

    def doCmd(self):
        """
        Executes the update of the param.
        """
        print "UNDO Int3D : ", self._index
        self._param.getTuttleParam().setValue(self._newValues)
        self._param.setOldValueAt(int(self._newValues[int(self._index)]), self._index)
        self._param.changed()

        from buttleofx.data import ButtleDataSingleton
        buttleData = ButtleDataSingleton().get()
        buttleData.updateMapAndViewer()
