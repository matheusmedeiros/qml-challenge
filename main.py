# This Python file uses the following encoding: utf-8
#
import json
import os
import sys
import urllib
import urllib.request

from PySide2.QtCore import QStringListModel, Qt, QUrl, QObject, Slot, Signal, QThread
from PySide2.QtGui import QGuiApplication
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtQuick import QQuickView

def pretty_date(time=False):
    from datetime import datetime
    now = datetime.now()
    if type(time) is int:
        diff = now - datetime.fromtimestamp(time)
    elif isinstance(time,datetime):
        diff = now - time
    elif not time:
        diff = now - now
    second_diff = diff.seconds
    day_diff = diff.days

    if day_diff < 0:
        return ''

    if day_diff == 0:
        if second_diff < 10:
            return "just now"
        if second_diff < 60:
            return str(second_diff) + " seconds ago"
        if second_diff < 120:
            return "a minute ago"
        if second_diff < 3600:
            return str(int(second_diff / 60)) + " minutes ago"
        if second_diff < 7200:
            return "an hour ago"
        if second_diff < 86400:
            return str(int(second_diff / 3600)) + " hours ago"
    if day_diff == 1:
        return "Yesterday"
    if day_diff < 7:
        return str(day_diff) + " days ago"
    if day_diff < 31:
        return str(int(day_diff / 7)) + " weeks ago"
    if day_diff < 365:
        return str(int(day_diff / 30)) + " months ago"
    return str(int(day_diff / 365)) + " years ago"

class Backend(QObject):
    listLoaded = Signal("QVariantList", name='listLoaded')
    storyLoaded = Signal("QVariant", name='storyLoaded')

    def __init__(self, parent=None):
        QObject.__init__(self, parent)

    @Slot()
    def loadStories(self):
        def load():
            url = "https://hacker-news.firebaseio.com/v0/topstories.json"
            response = urllib.request.urlopen(url)
            items = json.loads(response.read().decode('utf-8'))
            self.listLoaded.emit(items[:20])
        Threader(load, self).start()

    @Slot(int)
    def loadStory(self, id):
        def load():
            url = f"https://hacker-news.firebaseio.com/v0/item/{id}.json"
            response = urllib.request.urlopen(url)
            data = json.loads(response.read().decode('utf-8'))
            data['time'] = pretty_date(data['time'])
            data['kids'] = len(data['kids'])
            self.storyLoaded.emit(data)
        Threader(load, self).start()


class Threader(QThread):
    def __init__(self, core, parent=None):
        super(Threader, self).__init__(parent)
        self._core = core

    def run(self):
        self._core()

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    backend = Backend()
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", backend)
    engine.load(QUrl.fromLocalFile('view.qml'))
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
