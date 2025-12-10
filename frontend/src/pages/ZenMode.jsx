import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Wind, CloudRain, Trees, Volume2, ArrowLeft, Maximize2, X, Clock, CheckCircle, RotateCcw, Award } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const ZenMode = () => {
    const navigate = useNavigate();
    const [isPlaying, setIsPlaying] = useState(false);
    const [activeSound, setActiveSound] = useState(null);
    const [volume, setVolume] = useState(0.5);
    const [breathingState, setBreathingState] = useState('inhale');
    const [instruction, setInstruction] = useState('Inhale...');
    const [isPressed, setIsPressed] = useState(false);
    const [syncStatus, setSyncStatus] = useState('neutral');

    // Timer State
    const [duration, setDuration] = useState(60); // 60s default
    const [timeLeft, setTimeLeft] = useState(60);
    const [sessionComplete, setSessionComplete] = useState(false);

    const audioRef = useRef(new Audio());

    const sounds = [
        { id: 'rain', name: 'Rain', icon: CloudRain, url: 'https://assets.mixkit.co/active_storage/sfx/2515/2515-preview.mp3' },
        { id: 'forest', name: 'Forest', icon: Trees, url: 'https://assets.mixkit.co/active_storage/sfx/2523/2523-preview.mp3' },
        { id: 'wind', name: 'Wind', icon: Wind, url: 'https://assets.mixkit.co/active_storage/sfx/1256/1256-preview.mp3' },
        { id: 'white', name: 'White Noise', icon: Volume2, url: 'https://assets.mixkit.co/active_storage/sfx/2568/2568-preview.mp3' }
    ];

    // Listeners
    useEffect(() => {
        const handleDown = (e) => { if (e.code === 'Space' || e.type === 'mousedown' || e.type === 'touchstart') setIsPressed(true); };
        const handleUp = (e) => { if (e.code === 'Space' || e.type === 'mouseup' || e.type === 'touchend') setIsPressed(false); };
        window.addEventListener('keydown', handleDown);
        window.addEventListener('keyup', handleUp);
        window.addEventListener('mousedown', handleDown);
        window.addEventListener('mouseup', handleUp);
        window.addEventListener('touchstart', handleDown);
        window.addEventListener('touchend', handleUp);
        return () => {
            window.removeEventListener('keydown', handleDown);
            window.removeEventListener('keyup', handleUp);
            window.removeEventListener('mousedown', handleDown);
            window.removeEventListener('mouseup', handleUp);
            window.removeEventListener('touchstart', handleDown);
            window.removeEventListener('touchend', handleUp);
        };
    }, []);

    // Sync Logic
    useEffect(() => {
        const shouldHold = breathingState === 'inhale' || breathingState === 'hold';
        setSyncStatus(isPressed === shouldHold ? 'good' : 'bad');
    }, [isPressed, breathingState]);

    // Timer Logic - ONLY runs if Sync is Good
    useEffect(() => {
        if (sessionComplete || timeLeft <= 0) return;

        let interval = null;
        if (syncStatus === 'good') {
            interval = setInterval(() => {
                setTimeLeft(t => {
                    if (t <= 1) {
                        setSessionComplete(true);
                        setIsPlaying(false);
                        return 0;
                    }
                    return t - 1;
                });
            }, 1000);
        }
        return () => clearInterval(interval);
    }, [syncStatus, timeLeft, sessionComplete]);

    // Breathing Logic (4-4-4)
    useEffect(() => {
        if (sessionComplete) return;
        const cycle = () => {
            setBreathingState('inhale');
            setInstruction('Inhale... (Hold Space)');
            setTimeout(() => {
                setBreathingState('hold');
                setInstruction('Hold... (Keep Holding)');
                setTimeout(() => {
                    setBreathingState('exhale');
                    setInstruction('Exhale... (Release)');
                }, 4000);
            }, 4000);
        };
        cycle();
        const interval = setInterval(cycle, 12000);
        return () => clearInterval(interval);
    }, [sessionComplete]);

    // Audio
    useEffect(() => {
        if (activeSound && !sessionComplete) {
            audioRef.current.crossOrigin = "anonymous";
            audioRef.current.src = activeSound.url;
            audioRef.current.loop = true;
            audioRef.current.volume = volume;
            audioRef.current.play().catch(e => console.log(e));
            setIsPlaying(true);
        } else {
            audioRef.current.pause();
            setIsPlaying(false);
        }
    }, [activeSound, sessionComplete]);

    useEffect(() => {
        audioRef.current.volume = volume;
    }, [volume]);

    const formatTime = (s) => {
        const m = Math.floor(s / 60);
        const sec = s % 60;
        return `${m}:${sec.toString().padStart(2, '0')}`;
    }

    return (
        <div className="min-h-screen bg-[#0f172a] text-white flex flex-col relative overflow-hidden font-sans">
            {/* Background */}
            <div className={`absolute inset-0 transition-opacity duration-1000 ${activeSound ? 'opacity-30' : 'opacity-0'}`}>
                <div className="absolute inset-0 bg-gradient-to-b from-blue-900/20 to-teal-900/20 animate-pulse" />
            </div>

            {/* Navbar & Timer */}
            <nav className="p-6 flex justify-between items-center z-20">
                <button onClick={() => navigate('/dashboard')} className="p-2 rounded-full hover:bg-white/10 transition-colors">
                    <ArrowLeft className="text-gray-400 hover:text-white" />
                </button>

                {/* Timer Display */}
                <div className="flex items-center gap-4 bg-white/5 px-4 py-2 rounded-full backdrop-blur-md border border-white/10">
                    <Clock size={16} className={syncStatus === 'good' ? "text-green-400" : "text-gray-400"} />
                    <span className="font-mono text-xl">{formatTime(timeLeft)}</span>
                    <div className="flex gap-1 ml-2">
                        {[60, 120, 300].map(t => (
                            <button
                                key={t}
                                onClick={() => { setDuration(t); setTimeLeft(t); setSessionComplete(false); }}
                                className={`text-xs px-2 py-1 rounded hover:bg-white/10 ${duration === t ? 'text-primary' : 'text-gray-500'}`}
                            >
                                {t / 60}m
                            </button>
                        ))}
                    </div>
                </div>
                <div className="w-10" />
            </nav>

            {/* Main Content */}
            <main className="flex-1 flex flex-col items-center justify-center relative z-10">
                {/* Warning Popup */}
                <AnimatePresence>
                    {syncStatus === 'bad' && !sessionComplete && (
                        <motion.div
                            initial={{ opacity: 0, y: -20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
                            className="absolute top-4 z-50 bg-red-500/20 border border-red-500/50 px-6 py-2 rounded-full text-red-200 font-medium backdrop-blur-md"
                        >
                            ⚠️ Hold Space to Sync & Continue Timer
                        </motion.div>
                    )}
                </AnimatePresence>

                {/* Completion Modal */}
                <AnimatePresence>
                    {sessionComplete && (
                        <motion.div
                            initial={{ scale: 0.8, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
                            className="absolute inset-0 z-50 flex flex-col items-center justify-center bg-black/80 backdrop-blur-sm p-4"
                        >
                            <Award size={64} className="text-yellow-400 mb-6 drop-shadow-glow" />
                            <h2 className="text-4xl font-bold text-white mb-2">Session Complete!</h2>
                            <p className="text-gray-300 text-lg mb-8 max-w-sm text-center">
                                "Quiet the mind, and the soul will speak." <br /> Great job centering yourself.
                            </p>
                            <div className="flex gap-4">
                                <button onClick={() => navigate('/dashboard')} className="btn-primary px-8 py-3">Back to Dashboard</button>
                                <button onClick={() => { setTimeLeft(duration); setSessionComplete(false); }} className="px-8 py-3 border border-white/20 rounded-xl hover:bg-white/10">Restart</button>
                            </div>
                        </motion.div>
                    )}
                </AnimatePresence>

                <div className="relative flex items-center justify-center">
                    {/* The Bubble */}
                    <motion.div
                        animate={{
                            scale: breathingState === 'inhale' ? 1.5 : breathingState === 'hold' ? 1.5 : 1,
                            opacity: breathingState === 'exhale' ? 0.6 : 1,
                            filter: syncStatus === 'good' ? 'hue-rotate(0deg)' : 'grayscale(100%) brightness(0.5)',
                        }}
                        transition={{ duration: 4, ease: "easeInOut" }}
                        className={`w-48 h-48 md:w-64 md:h-64 rounded-full bg-gradient-to-tr from-cyan-300 via-blue-500 to-purple-600 blur-2xl relative z-0 transition-opacity duration-500 ${syncStatus === 'good' ? 'opacity-100' : 'opacity-50'}`}
                    />
                    <motion.div
                        animate={{
                            scale: breathingState === 'inhale' ? 1.3 : breathingState === 'hold' ? 1.3 : 1,
                        }}
                        transition={{ duration: 4, ease: "easeInOut" }}
                        className={`absolute w-48 h-48 md:w-64 md:h-64 rounded-full border-2 z-10 flex items-center justify-center backdrop-blur-sm bg-white/5 transition-colors duration-300 ${syncStatus === 'good' ? 'border-white/20' : 'border-red-500/30'}`}
                    >
                        <motion.span
                            key={instruction}
                            initial={{ opacity: 0 }}
                            animate={{ opacity: 1 }}
                            exit={{ opacity: 0 }}
                            className="text-xl md:text-2xl font-light tracking-widest text-center"
                        >
                            {instruction.split('...')[0]}
                        </motion.span>
                    </motion.div>
                </div>

                <p className={`mt-32 text-sm max-w-xs text-center transition-colors duration-500 ${syncStatus === 'good' ? 'text-green-400 font-bold' : 'text-gray-400'}`}>
                    {syncStatus === 'good' ? "Perfect Sync ✨" : "Follow the rhythm... Hold Space to Inhale"}
                </p>
            </main>

            {/* Soundscapes Dock */}
            <footer className="p-8 z-20">
                <div className="max-w-xl mx-auto glass-card p-4 rounded-3xl flex flex-col md:flex-row items-center justify-between gap-4">
                    <div className="flex flex-wrap justify-center gap-2">
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
