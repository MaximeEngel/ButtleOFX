import logging
from PySide import QtCore


class ConnectionWrapper(QtCore.QObject):
    """
        Class ConnectionWrapper defined by :
            - _connection : the buttle connection
    """

    def __init__(self, connection, view):
        super(ConnectionWrapper, self).__init__(view)

        self._connection = connection

        # the link between the connection and the connectionWarpper
        self._connection.connectionClipOutChanged.connect(self.emitConnectionClipOutChanged)
        self._connection.connectionClipInChanged.connect(self.emitConnectionClipInChanged)

        logging.info("Gui : ConnectionWrapper created")

    def __str__(self):
        return 'Connection between the clip "%s (%s %d)" and the clip "%s (%s %d)' % (self._connection._clipOut._nodeName, self._connection._clipOut._port, self._connection._clipOut._clipNumber, self._connection._clipIn._nodeName, self._connection._clipIn._port, self._connection._clipIn._clipNumber)

    def __del__(self):
        logging.info("Gui : ConnectionWrapper deleted")

    ######## getters ########

    def getConnection(self):
        return self._connection

    def getId(self):
        return self._connection.getId()

    def getClipOutPosX(self):
        return self._connection.getClipOut().getCoord()[0]

    def getClipOutPosY(self):
        return self._connection.getClipOut().getCoord()[1]

    def getClipInPosX(self):
        return self._connection.getClipIn().getCoord()[0]

    def getClipInPosY(self):
        return self._connection.getClipIn().getCoord()[1]

    ######## setters ########

    def setClipOutPosX(self, posX):
        self._connection.getClipOut().setXCoord(posX)

    def setClipOutPosY(self, posY):
        self._connection.getClipOut().setYCoord(posY)

    def setClipInPosX(self, posX):
        self._connection.getClipIn().setXCoord(posX)

    def setClipInPosY(self, posY):
        self._connection.getClipIn().setYCoord(posY)

    ################################################## LINK WRAPPER LAYER TO QML ##################################################

    @QtCore.Signal
    def connectionClipOutChanged(self):
        pass

    def emitConnectionClipOutChanged(self):
        self.connectionClipOutChanged.emit()

    @QtCore.Signal
    def connectionClipInChanged(self):
        pass

    def emitConnectionClipInChanged(self):
        self.connectionClipInChanged.emit()

    ################################################## DATA EXPOSED TO QML ##################################################

    clipOutPosX = QtCore.Property(int, getClipOutPosX, setClipOutPosX, notify=connectionClipOutChanged)
    clipOutPosY = QtCore.Property(int, getClipOutPosY, setClipOutPosX, notify=connectionClipOutChanged)

    clipInPosX = QtCore.Property(int, getClipInPosX, setClipInPosX, notify=connectionClipInChanged)
    clipInPosY = QtCore.Property(int, getClipInPosY, setClipInPosX, notify=connectionClipInChanged)
