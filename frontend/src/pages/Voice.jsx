import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Mic, MicOff, X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios'; // Import axios

export default function Voice() {
    const navigate = useNavigate();
    const [isListening, setIsListening] = useState(false);
    const [transcript, setTranscript] = useState("Tap the microphone to speak...");

    const toggleListen = async () => {
        if (!isListening) {
            setIsListening(true);
            setTranscript("Listening...");
            // Simulate recording & API call delay
            setTimeout(async () => {
                try {
                    // Note: FastAPI Form param expects form-data or urlencoded, but let's just send JSON if we changed backend to Body.
                    // The backend expects Form for transcript.
                    const formData = new FormData();
                    formData.append('transcript', "I am feeling a bit bored and tired.");

                    const apiRes = await axios.post('http://localhost:8000/api/v1/voice-input', formData);
                    setTranscript(`You seem ${apiRes.data.mood}. Suggesting: ${apiRes.data.action}`);
                } catch (e) {
                    console.error(e);
                    setTranscript("Error processing voice.");
                }
                setIsListening(false);
            }, 3000);
        } else {
            setIsListening(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black z-50 flex flex-col items-center justify-center overflow-hidden">
            {/* Background Waves */}
            {items.map((_, i) => (
                <motion.div
                    key={i}
                    animate={{ scale: isListening ? [1, 2, 1] : 1, opacity: isListening ? [0.5, 0, 0.5] : 0.1 }}
                    transition={{ duration: 2, repeat: Infinity, delay: i * 0.2 }}
                    className="absolute rounded-full border border-primary/50"
                    style={{
                        width: `${(i + 1) * 200}px`,
                        height: `${(i + 1) * 200}px`,
                    }}
                />
            ))}

            <button onClick={() => navigate('/dashboard')} className="absolute top-8 right-8 p-3 rounded-full bg-white/10 hover:bg-white/20 transition-colors z-50">
                <X size={24} />
            </button>

            <div className="relative z-10 text-center">
                <motion.button
                    onClick={toggleListen}
                    animate={{ scale: isListening ? 1.2 : 1 }}
                    className={`w-32 h-32 rounded-full flex items-center justify-center transition-all duration-500 shadow-[0_0_50px_rgba(139,92,246,0.3)] ${isListening ? 'bg-gradient-to-tr from-primary to-neon-purple' : 'bg-gray-800'
                        }`}
                >
                    {isListening ? <Mic size={48} className="text-white" /> : <MicOff size={48} className="text-gray-400" />}
                </motion.button>

                <div className="mt-12 h-20">
                    <p className="text-2xl font-light text-gray-300 max-w-lg mx-auto leading-relaxed">
                        "{transcript}"
                    </p>
                </div>
            </div>
        </div>
    );
}

const items = Array.from({ length: 5 });
