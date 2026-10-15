import React from 'react';

interface ConcentricRingProps {
  values: number[]; // e.g. [0.75, 0.40, 0.90] (0 to 1)
  colors: string[]; // e.g. ['#A8E6D8', '#E8E48C', '#E3B8F5']
  size?: number;
  children?: React.ReactNode;
}

export const ConcentricRing: React.FC<ConcentricRingProps> = ({
  values,
  colors,
  size = 200,
  children,
}) => {
  const strokeWidth = Math.min(14, Math.max(6, size / 14));
  const center = size / 2;

  return (
    <div
      className="relative flex items-center justify-center select-none"
      style={{ width: size, height: size }}
    >
      <svg
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
        className="transform -rotate-90"
      >
        {values.map((rawVal, index) => {
          const val = Math.min(1.0, Math.max(0.0, rawVal));
          const radius = center - strokeWidth / 2 - index * (strokeWidth * 1.45);
          if (radius <= strokeWidth) return null;

          const circumference = 2 * Math.PI * radius;
          const strokeDashoffset = circumference * (1 - val);
          const color = colors[index % colors.length];

          return (
            <g key={index}>
              {/* Background Track */}
              <circle
                cx={center}
                cy={center}
                r={radius}
                fill="none"
                stroke="rgba(255, 255, 255, 0.07)"
                strokeWidth={strokeWidth}
              />
              {/* Active Progress Arc */}
              {val > 0.001 && (
                <circle
                  cx={center}
                  cy={center}
                  r={radius}
                  fill="none"
                  stroke={color}
                  strokeWidth={strokeWidth}
                  strokeDasharray={circumference}
                  strokeDashoffset={strokeDashoffset}
                  strokeLinecap="round"
                  style={{
                    transition: 'stroke-dashoffset 0.85s cubic-bezier(0.2, 0, 0, 1)',
                    filter: `drop-shadow(0 0 6px ${color}33)`,
                  }}
                />
              )}
            </g>
          );
        })}
      </svg>
      {children && (
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
          {children}
        </div>
      )}
    </div>
  );
};
