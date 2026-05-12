/*
 * shirOS — slideshow Calamares
 * Se muestra durante la instalación.
 */
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    function nextSlide() {
        presentation.goToNextSlide();
    }

    Timer {
        interval: 7000
        running: true
        repeat: true
        onTriggered: nextSlide()
    }

    Slide {
        Image {
            id: slide1
            source: "slide1.svg"
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            text: "<b>Bienvenido a shirOS</b><br>" +
                  "Un sistema simple, rápido y compatible para tu trabajo."
            color: "#1F2937"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Slide {
        Image {
            source: "slide2.svg"
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            text: "<b>Velocidad</b><br>" +
                  "Boot en menos de 20 segundos. Listo cuando vos lo estés."
            color: "#1F2937"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Slide {
        Image {
            source: "slide3.svg"
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            text: "<b>Detecta todo</b><br>" +
                  "Impresoras, monitores externos, WiFi: out-of-the-box."
            color: "#1F2937"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Slide {
        Image {
            source: "slide4.svg"
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            text: "<b>Apps que ya conocés</b><br>" +
                  "Google, Microsoft 365, Zoom, Teams. Todo funciona."
            color: "#1F2937"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
