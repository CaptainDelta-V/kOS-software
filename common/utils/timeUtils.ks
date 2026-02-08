

Global Function SecondsToTimeDisplay {
    Parameter theSeconds.

    Local inputSeconds to Abs(theSeconds).

    Local minutes to Floor(inputSeconds / 60).
    Local seconds to mod(inputSeconds, 60).

    Return Round(minutes) + ":" + Round(seconds).
}