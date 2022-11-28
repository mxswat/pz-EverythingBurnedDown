'use strict';

function insideCircle() {
    let size = 11
    let pzMap = Array(size).fill(Array(size).fill(" "));
    const circleX = 5
    const circleY = 5
    const circleRadius = 4
    console.log({
        size,
        circleX,
        circleY,
        circleRadius,
    })
    const isInsideCircle = (x, y) => {
        // NOTE: not using <=, using <
        return Math.sqrt(Math.pow(x - circleX, 2) + Math.pow((y - circleY), 2)) < circleRadius;
    }

    const editedMap = pzMap.map((row, x) => {
        return row.map((col, y) => {
            if (x == circleX && y == circleY) {
                return 'O'
            }
            if (isInsideCircle(x, y)) {
                return 'X'
            }
            return '.'
        })
    })

    const output = editedMap.map((x) => x.join('')).join('\n')
    console.log(editedMap)
    console.log(output)
}
insideCircle()

// ......X......
// ...XXXXXXX...
// ..XXXXXXXXX..
// .XXXXXXXXXXX.
// .XXXXXXXXXXX.
// .XXXXXXXXXXX.
// XXXXXXOXXXXXX
// .XXXXXXXXXXX.
// .XXXXXXXXXXX.
// .XXXXXXXXXXX.
// ..XXXXXXXXX..
// ...XXXXXXX...
// ......X......

// ----------------------------------

// Matrix is

const drawLine = ({ x0, x1, y, matrix }) => {
    matrix[Math.round(y + 0.5)] = matrix[Math.round(y + 0.5)].fill('X', Math.round(x1), Math.round(x0 + 1))
}

const fillCircle = ({ cx, cy, radius, matrix }) => {
    let x = radius - 1
    let y = 0
    let dx = 1
    let dy = 1
    let err = dx - (radius << 1)

    while (x >= y) {
        drawLine({ x0: cx + y, x1: cx - y, y: cy - x, matrix })
        drawLine({ x0: cx + x, x1: cx - x, y: cy - y, matrix })
        drawLine({ x0: cx + x, x1: cx - x, y: cy + y, matrix })
        drawLine({ x0: cx + y, x1: cx - y, y: cy + x, matrix })

        if (err <= 0) {
            y++
            err += dy
            dy += 2
        }

        if (err > 0) {
            x--
            dx += 2
            err += dx - (radius << 1)
        }

        console.log({x, y, err})
    }

    console.log(matrix.map((x) => x.join('')).join('\n'))
}

const size = 21
const matrix = Array.from({ length: 21 }, e => Array(21).fill('.'));
fillCircle({
    cx: (size / 2) - 1,
    cy: (size / 2) - 1,
    radius: 6,
    matrix,
})