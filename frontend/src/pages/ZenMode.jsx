import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Wind, CloudRain, Trees, Volume2, ArrowLeft, Maximize2, X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const ZenMode = () => {
    const navigate = useNavigate();
    const [isPlaying, setIsPlaying] = useState(false);
    const [activeSound, setActiveSound] = useState(null);
    const [volume, setVolume] = useState(0.5);
    const [breathingState, setBreathingState] = useState('inhale'); // inhale, hold, exhale
    const [instruction, setInstruction] = useState('Inhale...');
    const audioRef = useRef(new Audio());

    const sounds = [
        { id: 'rain', name: 'Rain', icon: CloudRain, url: 'https://cdn.pixabay.com/download/audio/2022/07/04/audio_307e246f41.mp3?filename=rain-112356.mp3' },
        { id: 'forest', name: 'Forest', icon: Trees, url: 'https://cdn.pixabay.com/download/audio/2021/09/06/audio_0af6470877.mp3?filename=forest-birds-11434.mp3' },
        { id: 'wind', name: 'Wind', icon: Wind, url: 'https://cdn.pixabay.com/download/audio/2022/01/18/audio_d0a13f69d2.mp3?filename=windy-tree-loop-103597.mp3' },
        { id: 'white', name: 'White Noise', icon: Volume2, url: 'https://cdn.pixabay.com/download/audio/2021/11/24/audio_82c6a46e12.mp3?filename=white-noise-8120.mp3' }
    ];

    // Breathing Cycle Logic (4-7-8 Technique turned into 4-4-4 for simplicity)
    useEffect(() => {
        const cycle = () => {
            setBreathingState('inhale');
            setInstruction('Inhale... (4s)');
            setTimeout(() => {
                setBreathingState('hold');
                setInstruction('Hold... (4s)');
                setTimeout(() => {
                    setBreathingState('exhale');
                    setInstruction('Exhale... (4s)');
                }, 4000);
            }, 4000);
        };

        cycle();
        const interval = setInterval(cycle, 12000); // 4+4+4 = 12s
        return () => clearInterval(interval);
    }, []);

    // Audio Logic
    useEffect(() => {
        if (activeSound) {
            audioRef.current.src = activeSound.url;
            audioRef.current.loop = true;
            audioRef.current.volume = volume;
            audioRef.current.play().catch(e => console.log("Audio play failed:", e));
            setIsPlaying(true);
        } else {
            audioRef.current.pause();
            setIsPlaying(false);
        }
    }, [activeSound]);

    useEffect(() => {
        audioRef.current.volume = volume;
    }, [volume]);

    return (
        <div className="min-h-screen bg-[#0f172a] text-white flex flex-col relative overflow-hidden font-sans">
            {/* Background Ambience */}
            <div className={`absolute inset-0 transition-opacity duration-1000 ${activeSound ? 'opacity-30' : 'opacity-0'}`}>
                <div className="absolute inset-0 bg-gradient-to-b from-blue-900/20 to-teal-900/20 animate-pulse" />
            </div>

            {/* Navbar */}
            <nav className="p-6 flex justify-between items-center z-20">
                <button
                    onClick={() => navigate('/dashboard')}
                    className="p-2 rounded-full hover:bg-white/10 transition-colors"
                >
                    <ArrowLeft className="text-gray-400 hover:text-white" />
                </button>
                <div className="text-sm font-medium tracking-widest uppercase text-gray-500">Zen Mode</div>
                <div className="w-10" /> {/* Spacer */}
            </nav>

            {/* Main Content: Breathing Bubble */}
            <main className="flex-1 flex flex-col items-center justify-center relative z-10">
                <div className="relative flex items-center justify-center">
                    {/* The Bubble */}
                    <motion.div
                        animate={{
                            scale: breathingState === 'inhale' ? 1.5 : breathingState === 'hold' ? 1.5 : 1,
                            opacity: breathingState === 'exhale' ? 0.6 : 1,
                        }}
                        transition={{ duration: 4, ease: "easeInOut" }}
                        className="w-48 h-48 md:w-64 md:h-64 rounded-full bg-gradient-to-tr from-cyan-300 via-blue-500 to-purple-600 blur-2xl relative z-0"
                    />
                    <motion.div
                        animate={{
                            scale: breathingState === 'inhale' ? 1.3 : breathingState === 'hold' ? 1.3 : 1,
                        }}
                        transition={{ duration: 4, ease: "easeInOut" }}
                        className="absolute w-48 h-48 md:w-64 md:h-64 rounded-full border-2 border-white/20 z-10 flex items-center justify-center backdrop-blur-sm bg-white/5"
                    >
                        <motion.span
                            key={instruction}
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            className="text-xl md:text-2xl font-light tracking-widest"
                        >
                            {instruction.split('...')[0]}
                        </motion.span>
                    </motion.div>
                </div>

                <p className="mt-12 text-gray-400 text-sm max-w-xs text-center">
                    Follow the rhythm. Focus on the circle. Let your thoughts drift away.
                </p>
            </main>

            {/* Soundscapes Dock */}
            <footer className="p-8 z-20">
                <div className="max-w-xl mx-auto glass-card p-4 rounded-3xl flex items-center justify-between gap-4">
                    <div className="flex gap-2 overflow-x-auto pb-2 md:pb-0 scrollbar-hide">
                        {sounds.map((sound) => (
                            <button
                                key={sound.id}
                                onClick={() => setActiveSound(activeSound?.id === sound.id ? null : sound)}
                                className={`flex flex-col items-center gap-1 p-3 rounded-2xl transition-all min-w-[70px] ${activeSound?.id === sound.id
                                        ? 'bg-primary text-white shadow-lg shadow-primary/30 scale-105'
                                        : 'hover:bg-white/10 text-gray-400 hover:text-white'
                                    }`}
                            >
                                <sound.icon size={20} />
                                <span className="text-[10px] uppercase font-bold tracking-wider">{sound.name}</span>
                            </button>
                        ))}
                    </div>

                    <div className="h-8 w-[1px] bg-white/10 hidden md:block" />

                    <div className="hidden md:flex items-center gap-2 min-w-[120px]">
                        <Volume2 size={16} className="text-gray-400" />
                        <input
                            type="range"
                            min="0"
                            max="1"
                            step="0.1"
                            value={volume}
                            onChange={(e) => setVolume(parseFloat(e.target.value))}
                            className="w-full accent-primary h-1 bg-white/20 rounded-full appearance-none cursor-pointer"
                        />
                    </div>
                </div>
            </footer>
        </div>
    );
};

export default ZenMode;
