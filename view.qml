import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.12

import "./components";

ApplicationWindow {
    id: mainWindow;
    title: "Hacker News";
    width: 640;
    height: 480;
    visible: true;

    property var prevStoriesList: [];

    /* startup connects backend signals to a local methods and invokes loadStories. */
    readonly property var startup: () => { 
      /*
       * loadEachStory receives storyIds from listLoaded signal and calls loadStory for each id.
       *
       * storyIds - An array with IDs corresponding to stories
       */
        const loadEachStory = (storyIds) => {
            storyIds.forEach(id => backend.loadStory(id));
        };

       /*
        * setStoriesList receives a story and pre-saves it in the prevStoriesList property.
        * Ends by restarting the timer of timerToSetList.
        *
        * story - An object with title, time, by, descendants, score and url properties.
        */
        const setStoriesList = (story) => {
            prevStoriesList.push(story);

            timerToSetList.restart();
        };

        backend.listLoaded.connect(loadEachStory);
        backend.storyLoaded.connect(setStoriesList);
        backend.loadStories();
    }

    /*
    * setStoriesList assigns orderedList to storiesList and sets isLoading to false from list
    * when prevStoriesList is not empty.
    */
    readonly property var setStoriesList: () => {
        if (prevStoriesList.length === 0) {
            return;
        }

        /* Sorts prevStoriesList from highest to lowest score and returns a new array. */
        const orderedList = prevStoriesList.sort((prev, newValue) => {
            return newValue.score - prev.score;
        });

        storiesList.append(orderedList);
        list.isLoading = false;
    }

    /*
    * This Timer is used like a debounce to wait for loading a considerable number of stories
    * and then triggers setStoriesList.
    */
    Timer {
        id: timerToSetList;
        interval: 1000;
        running: true;
        repeat: false;
        triggeredOnStart: false;
        onTriggered: setStoriesList();
    }

    ListModel {
        id: storiesList;
    }

    ListView {
        id: list;

        property bool isLoading: true;

        width: parent.width;
        height: parent.height;

        model: storiesList;
        delegate: LinkPreview {}

        BusyIndicator {
            anchors.centerIn: parent;
            running: list.isLoading;
        }
    }

    Component.onCompleted: startup();
}
