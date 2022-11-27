'use strict';

let size = 51
let pzMap = Array(size).fill(Array(size).fill(" "));
const circleX = Math.floor(size / 2)
const circleY = Math.floor(size / 2)
const circleRadius = 20

const isInsideCircle = (x, y) => {
    return Math.sqrt(Math.pow(x - circleX, 2) + Math.pow((y - circleY), 2)) <= circleRadius;
}

const editedMap = pzMap.map((row, x) => {
    return row.map((col, y) => {
        if (x == circleX && y == circleY) {
            return 'O'
        }
        if (isInsideCircle(x ,y)) {
            return 'X'
        }
        return '.'
    })
})

const output = editedMap.map((x) => x.join('')).join('\n')

console.log(output)