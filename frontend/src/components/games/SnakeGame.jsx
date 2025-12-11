import { useState, useEffect, useRef, useCallback } from 'react';
import { RotateCcw, Trophy, ArrowUp, ArrowDown, ArrowLeft, ArrowRight } from 'lucide-react';

const SnakeGame = ({ onBack }) => {
    const canvasRef = useRef(null);
    const [gameState, setGameState] = useState('menu'); // menu, playing, gameover
    const [score, setScore] = useState(0);

    // Game Config
    const GRID_SIZE = 20;
    const GAME_SPEED = 100;

    // Game State Refs
    const snakeRef = useRef([{ x: 10, y: 10 }]);
    const foodRef = useRef({ x: 15, y: 15 });
    const dirRef = useRef({ x: 1, y: 0 });
    const nextDirRef = useRef({ x: 1, y: 0 });
    const gameLoopRef = useRef(null);

    const spawnFood = () => {
        const x = Math.floor(Math.random() * (400 / GRID_SIZE));
        const y = Math.floor(Math.random() * (400 / GRID_SIZE));
        // Ensure food doesn't spawn on snake
        foodRef.current = { x, y };
    };

    const draw = useCallback(() => {
        const canvas = canvasRef.current;
        if (!canvas) return;
        const ctx = canvas.getContext('2d');

        // Clear
        ctx.fillStyle = '#1e293b';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Draw Snake
        ctx.fillStyle = '#4ade80';
        snakeRef.current.forEach((segment, i) => {
            // Head color slightly different
            if (i === 0) ctx.fillStyle = '#22c55e';
            else ctx.fillStyle = '#4ade80';
            ctx.fillRect(segment.x * GRID_SIZE, segment.y * GRID_SIZE, GRID_SIZE - 2, GRID_SIZE - 2);
        });

        // Draw Food
        ctx.fillStyle = '#ef4444';
        ctx.beginPath();
        const fx = foodRef.current.x * GRID_SIZE + GRID_SIZE / 2;
        const fy = foodRef.current.y * GRID_SIZE + GRID_SIZE / 2;
        ctx.arc(fx, fy, GRID_SIZE / 2 - 2, 0, Math.PI * 2);
        ctx.fill();
    }, []);

    const endGame = () => {
        if (gameLoopRef.current) clearInterval(gameLoopRef.current);
        setGameState('gameover');
    };

    const gameLoop = useCallback(() => {
        const snake = [...snakeRef.current];
        const head = { ...snake[0] };

        // Prevent 180 degree turns
        const currentDir = dirRef.current;
        const next = nextDirRef.current;

        // Only update direction if it's not a 180 turn
        if ((next.x !== 0 && next.x !== -currentDir.x) || (next.y !== 0 && next.y !== -currentDir.y)) {
            dirRef.current = next;
        }

        head.x += dirRef.current.x;
        head.y += dirRef.current.y;

        // Wall Collision
        if (head.x < 0 || head.x >= 400 / GRID_SIZE || head.y < 0 || head.y >= 400 / GRID_SIZE) {
            endGame();
            return;
        }

        // Self Collision
        if (snake.some(segment => segment.x === head.x && segment.y === head.y)) {
            endGame();
            return;
        }

        snake.unshift(head);

        // Food Collision
        if (head.x === foodRef.current.x && head.y === foodRef.current.y) {
            setScore(s => s + 1);
            spawnFood();
        } else {
            snake.pop();
        }

        snakeRef.current = snake;
        draw();
    }, [draw, endGame]);

    const startGame = () => {
        snakeRef.current = [{ x: 10, y: 10 }];
        dirRef.current = { x: 1, y: 0 };
        nextDirRef.current = { x: 1, y: 0 };
        setScore(0);
        setGameState('playing');
        spawnFood();

        if (gameLoopRef.current) clearInterval(gameLoopRef.current);
        gameLoopRef.current = setInterval(gameLoop, GAME_SPEED);
    };

    // Keyboard Controls
    useEffect(() => {
        const handleKey = (e) => {
            if (gameState !== 'playing') return;

            if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' '].includes(e.key)) {
                e.preventDefault();
            }

            switch (e.key) {
                case 'ArrowUp':
                    nextDirRef.current = { x: 0, y: -1 };
                    break;
                case 'ArrowDown':
                    nextDirRef.current = { x: 0, y: 1 };
                    break;
                case 'ArrowLeft':
                    nextDirRef.current = { x: -1, y: 0 };
                    break;
                case 'ArrowRight':
                    nextDirRef.current = { x: 1, y: 0 };
                    break;
            }
        };

        window.addEventListener('keydown', handleKey);
        return () => window.removeEventListener('keydown', handleKey);
    }, [gameState]);

    // Cleanup
    useEffect(() => {
        return () => {
            if (gameLoopRef.current) clearInterval(gameLoopRef.current);
        };
    }, []);

    // Initial Menu Draw
    useEffect(() => {
        if (gameState === 'menu' && canvasRef.current) {
            const ctx = canvasRef.current.getContext('2d');
            ctx.fillStyle = '#1e293b';
            ctx.fillRect(0, 0, 400, 400);
            ctx.font = "20px monospace";
            ctx.fillStyle = "#475569";
            ctx.textAlign = "center";
            ctx.fillText("PRESS START", 200, 200);
        }
    }, [gameState]);

    return (
        <div className="flex flex-col items-center justify-center p-4">
            <h2 className="text-3xl font-black mb-4 text-green-400">Snake</h2>

            <div className="relative border-4 border-slate-700 rounded-lg overflow-hidden shadow-2xl">
                <canvas
                    ref={canvasRef}
                    width={400}
                    height={400}
                    className="block bg-slate-900"
                />

                {gameState === 'menu' && (
                    <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/60 backdrop-blur-sm z-10">
                        <button onClick={startGame} className="btn-primary px-8 py-3 text-lg">Start Game</button>
                        <p className="mt-4 text-gray-400 text-sm">Use Arrow Keys to Move</p>
                    </div>
                )}

                {gameState === 'gameover' && (
                    <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/80 backdrop-blur-sm z-10">
                        <Trophy size={48} className="text-yellow-400 mb-2" />
                        <h3 className="text-3xl font-bold text-white mb-1">Game Over</h3>
                        <p className="text-gray-400 mb-6">Score: {score}</p>
                        <button onClick={startGame} className="btn-primary flex items-center gap-2 px-6 py-2">
                            <RotateCcw size={18} /> Retry
                        </button>
                    </div>
                )}
            </div>

            {/* Mobile Controls */}
            <div className="mt-6 grid grid-cols-3 gap-2 md:hidden">
                <div />
                <button className="bg-slate-700 p-4 rounded-full active:bg-slate-600" onClick={() => { if (dirRef.current.y === 0) nextDirRef.current = { x: 0, y: -1 } }}><ArrowUp /></button>
                <div />
                <button className="bg-slate-700 p-4 rounded-full active:bg-slate-600" onClick={() => { if (dirRef.current.x === 0) nextDirRef.current = { x: -1, y: 0 } }}><ArrowLeft /></button>
                <button className="bg-slate-700 p-4 rounded-full active:bg-slate-600" onClick={() => { if (dirRef.current.y === 0) nextDirRef.current = { x: 0, y: 1 } }}><ArrowDown /></button>
                <button className="bg-slate-700 p-4 rounded-full active:bg-slate-600" onClick={() => { if (dirRef.current.x === 0) nextDirRef.current = { x: 1, y: 0 } }}><ArrowRight /></button>
            </div>
        </div>
    );
};

export default SnakeGame;
