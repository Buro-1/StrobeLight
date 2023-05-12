# ``StrobeLight/BeatAnalyzer``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Weitere Details zur Signalverarbeitung

Die Fourier-Transformation ist ein mathematisches Verfahren, das eine Funktion oder ein Signal in seine Frequenzkomponenten aufteilt. Sie wird verwendet, um eine kontinuierliche Funktion oder ein Signal, das im Zeitbereich dargestellt ist, in den Frequenzbereich zu transformieren. Die Transformation ermöglicht es, die Frequenzspektren der Funktion oder des Signals zu analysieren und zu modifizieren.

Im Kontext der Verarbeitung von Audiodaten in der "StrobeLight" App wird die Fourier-Transformation eingesetzt, um die Musikdaten in den Frequenzbereich zu transformieren und die rhythmischen Muster der Musik zu identifizieren. Die Transformation wird auf kleine Zeitintervalle angewendet, um die Frequenzspektren der Audiosignale zu extrahieren. Die resultierenden Frequenzspektren werden dann analysiert, um die Beats und Rhythmen der Musik zu erkennen und entsprechend zu timen.
Im untersten Frequenzbereich 0 - 200 Hz befinden sich die Bässe, welche uns interessieren. Mittels FT werden diese isoliert und in diskrete "Bins" aufgeteilt. Ein Bin stellt dabei einen Frequenzbereich dar.

Ein Derivat ist ein mathematisches Konzept, das die Rate der Veränderung einer Funktion an einem bestimmten Punkt beschreibt. Es gibt an, wie schnell oder langsam sich eine Funktion ändert, wenn sich die Eingangsvariable (in der Regel die Zeit) verändert.

Das Derivat einer Funktion kann als Steigung oder Gradient der Funktion an einem bestimmten Punkt interpretiert werden. Es gibt an, wie schnell die Funktion an diesem Punkt steigt oder fällt. Das Derivat einer Funktion kann sowohl positiv als auch negativ sein, abhängig davon, ob die Funktion an diesem Punkt ansteigt oder fällt.

Die Ableitung kann auch als Grenzwert einer Funktion definiert werden, wenn die Differenz zwischen zwei nahe beieinander liegenden Eingabewerten gegen Null geht. Es gibt verschiedene Methoden zur Berechnung von Ableitungen, wie z.B. die Differenzierung, die Produktregel und die Kettenregel.

In der Praxis wird das Konzept der Ableitung in vielen Bereichen der Mathematik und der Naturwissenschaften angewendet, um die Veränderung von Größen wie Geschwindigkeit, Beschleunigung, Wachstum und Verfall zu quantifizieren. Es ist auch ein wichtiges Konzept in der Informatik, insbesondere bei der Optimierung von Algorithmen und der numerischen Analyse von Daten.


Für den untersten Bin wird das Derivat, das durchschnittliche Derivat und die Standardabweichung des durchschnittlichen Derivats laufend berechnet. Dies geschieht in so fern effizient, dass nicht eine Liste an Werten, sondern nur ein Zähler und der bis anhin erfasste Werte gespeichert werden.
Schlägt das Derivat über die 1.5x Standardabweichung aus, wird ein Blitz ausgelöst.

Hier nochmals im kompletten Schema:

![Komplettes Verarbeitungsschema](schema)

[Wikipedia](https://en.wikipedia.org/wiki/Beat_detection)
[Referenz, Algorithmus angepasst von hier](http://www.owlnet.rice.edu/~elec301/Projects01/beat_sync/beatalgo.html)
